#! /bin/bash
#
# make_machine.sh -- create a hetzner machine and return its ip address
#
# Study:
#  https://www.terraform.io/docs/configuration/variables.html
#  https://www.terraform.io/docs/providers/hcloud/index.html
#  https://gitea.owncloud.services/rkaussow/hcloud-playground
#  https://releases.hashicorp.com/terraform/0.12.12/
#
# jw, 2020-04-15	v0.1	initial draft
# jw, 2020-05-11	v0.2	package install option, remember names for later destroy
# jw, 2020-05-12	v0.3	poor man's option parser added. getopts is so silly. not used.
# jw, 2020-05-14	v0.4	%s interpolation on the machine name, support for direct login
version=0.4

if [ -z "$TF_VAR_hcloud_token" ]; then
  echo "Environment variable TF_VAR_hcloud_token not set."
  exit 1
fi
tf_url="https://releases.hashicorp.com/terraform/0.12.12/terraform_0.12.12_linux_amd64.zip"
ssh_key_names="$TF_SSHKEY_NAMES"
ssh_keys="$TF_SSHKEY"
packages=""
server_image="ubuntu-20.04"
datacenter="fsn1-dc14"
server_type="cx21"
do_login=false

# getopts cannot do long names and needs more code.
while [ "$#" -gt 0 ]; do
  case "$1" in
    -s|--ssh-key-names) ssh_key_names="$2"; shift ;;
    -d|--datacenter) datacenter="$2"; shift ;;
    -p|--packages) extra_pkg="$2"; shift ;;
    -i|--image) server_image="$2"; shift ;;
    -t|--type) server_type="$2"; shift ;;
    -h|--help) name="$1" ;;
    -l|--login) do_login=true ;;
    -*) echo "Unknown option '$1'. Try --help"; exit 1 ;;
    *) name="$1" ;;
  esac
  shift
done

test -z "$TF_USER" && TF_USER=$(echo "$ssh_key_names" | sed -e 's/[\s,@].*$//')
test -z "$TF_USER" && TF_USER=$USER

if [ "$name" = '-h' ]; then
  cat <<EOF
  make_machine.sh V$version

  Usage:
    export TF_SSHKEY_NAMES="jw@owncloud.com"
    export TF_VAR_hcloud_token=123..........xyz
    $0 [OPTIONS] MACHINE_NAME
    $0 [OPTIONS] %s-NAME-%s

  Where options are:

    -i|--image ...          server image. Default: $server_image
    -t|--type ...           server type. Default: $server_type
    -d|--datacenter ...	    server datacenter. Default: $datacenter
    -s|--ssh-key-names ...  comma-separated names of uploaded public keys
    -p|--packages ...       comma-separated list of linux packages to install
    -l|--login              ssh into the machine, when ready

  TF_VAR_hcloud_token is specific to a project at https://console.hetzner.cloud
  consult with the project owner to get a token.
  TF_SSHKEY_NAMES: comma-separated list of names of one or more.
  TF_SSHKEY: content of an ~/.ssh/id_XXX.pub file. This must not be an uploaded key.
  TF_USER is optional. Default: derived from the first element of \$TF_SSHKEY_NAMES or \$USER.

  The MACHINE_NAME should mention the user, and must be unique in the project.
  '%s' interpolation is done twice on the MACHINE_NAME. The first occurance,
  (if any) is replaced with TF_USER, the second occurance is replaced with a
  short random string.
  Example: '%s-eostest-%s' might result in 'jw-eostest-3z4ya'

  When the script finishes, you can extract the ip-address and the (exact) name with

    cd terraform
    bin/terraform output ipv4
    bin/terraform output name

EOF
  exit 1
fi

# convert comma-separated to whitespace separated:
extra_pkg=$(echo $extra_pkg | tr , ' ')

# convert to comma-separated to comma-separated quoted strings
ssh_key_names=$(echo '"'$ssh_key_names'"' | sed -e 's/,/","/')
test "$ssh_key_names" = '""' && ssh_key_names=''
ssh_keys=$(echo '"'$ssh_keys'"' | sed -e 's/,/","/')
test "$ssh_keys" = '""' && ssh_keys=''

if [ -z "$ssh_key_names$ssh_keys" ]; then
  echo "ERROR: No ssh-key specified. The machine cannot be accessed without one."
  echo "ERROR: Please set environment variable TF_SSHKEY_NAMES or TF_SSHKEY."
  exit 1
fi

if [ -z "$name" ]; then
  name="%s-$(echo "$server_image" | tr ._ -)-%s"
  echo "No MACHINE_NAME specified, generating one: '$name'"
fi

name_pattern=$name
name=$(printf "$name" "$TF_USER" "$(tr -dc 'a-z0-9' < /dev/urandom | head -c 5)")

if [ "$name" != "$name_pattern" ]; then
  echo "MACHINE_NAME '$name_pattern' expanded to '$name'"
fi

if [ ! -e "terraform/bin/terraform" ]; then
  mkdir -p terraform/bin
  wget $tf_url -O terraform/bin/tf.zip
  (cd terraform/bin; unzip tf.zip)
  rm terraform/bin/tf.zip
  chmod a+x terraform/bin/terraform
fi

cd terraform
# rm -rf .terraform             # here are hcloud plugins ...
rm -rf .cache           	# clean state
bin/terraform init

bin/terraform plan -var="server_owner=$TF_USER" -var="server_names=[\"$name\"]" \
                   -var="ssh_keys=[$ssh_keys]" -var="server_keys=[$ssh_key_names]" \
                   -var="server_datacenter=$datacenter" \
                   -var="server_types=[\"$server_type\"]" \
                   -var="server_image=$server_image" -out $name.plan

bin/terraform apply $name.plan
ipaddr=$(bin/terraform output ipv4)
test -z "$ipaddr" && exit 1

test -f .cache/terraform.tfstate && cp .cache/terraform.tfstate $name.tfstate

ssh-keygen -f ~/.ssh/known_hosts -R $ipaddr	# needed to make life easier later.
# StrictHostKeyChecking=no automatically adds new host keys and accepts changed host keys.

for i in 1 2 3 4 5 6 7 8 last; do
  sleep 5
  echo -n .
  ssh -o ConnectTimeout=5 -o CheckHostIP=no -o StrictHostKeyChecking=no -o PasswordAuthentication=no root@$(bin/terraform output ipv4) uptime && break
  if [ $i = last ]; then
    echo "Error: cannot ssh into machine at $ipaddr -- tried multiple times."
    exit 1
  fi
done

if [ -n "$extra_pkg" ]; then
  case "$server_image" in
    ubuntu*|debian*)
      ssh root@$ipaddr sh -x -s <<END
        apt-get update
        apt-get upgrade -y
        apt-get install -y $extra_pkg
END
	;;
    fedora*|centos*)
      ssh root@$ipaddr sh -x -s <<END
        yum install -y $extra_pkg
END
	;;
    *) echo "platform installer not implemented for $server_image. Skipping package installation of $extra_pkg"
        ;;
  esac
fi

rm -f $name.plan	# keeping $name.tftate should be enough...

if $do_login; then
  echo "+ ssh root@$ipaddr"
  ssh root@$ipaddr
  cat <<END
--------------------------------------------------
When no longer needed, please destroy the machine with e.g.

  ./destroy_machine.sh $name
--------------------------------------------------
END
  exit 0
fi

cat <<END
--------------------------------------------------
Machine created. Try

    ssh root@$ipaddr

To destroy the machine later, you can use

    ./destroy_machine.sh $name
--------------------------------------------------
END
sleep 2

exit 0
