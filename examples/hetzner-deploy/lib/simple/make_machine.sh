#! /bin/sh
version=0.4

exec 3>&1 1>&2	# all output goes to stderr.
set -e

name=
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

if [ "$name" = '-h' ]; then
  cat <<EOF
  make_machine.sh V$version

  Usage:
    export OC_DEPLOY_ADDR=localhost
    $0 [OPTIONS] (MACHINE_NAME)

  Where options are:

    -p|--packages ...       comma-separated list of linux packages to install

  Ignored options:
    -l|--login
    -i|--image
    -t|--type
    -d|--datacenter
    -s|--ssh-key-names

  The MACHINE_NAME is optional. Default is derived from OC_DEPLOY_ADDR

  "export ipaddr=... name=..." is printed on stdout describing the deploy target.
EOF
  exit 1
fi

if [ -z "$name" ]; then
  name="$(echo "$OC_DEPLOY_ADDR" | tr ._ -)"
fi

there="ssh -t root@$OC_DEPLOY_ADDR"
test "$OC_DEPLOY_ADDR" = localhost -o "$OC_DEPLOY_ADDR" = 127.0.0.1 && there=sudo

if [ -n "$extra_pkg" ]; then
  . /etc/os-release
  case "$ID" in
    linuxmint|ubuntu|debian)
      echo "+ $there apt-get install -y $extra_pkg"
      $there apt-get install -y $extra_pkg
	;;
    fedora|centos)
        echo "+ $there yum install -y $extra_pkg"
        $there yum install -y $extra_pkg
	;;
    *) echo "platform installer not implemented for $ID. Skipping package installation of $extra_pkg"
        ;;
  esac
fi

if [ "$do_login" = true ]; then
  $there bash	# sudo or ssh ...
fi

echo 1>&3 "export ipaddr=$OC_DEPLOY_ADDR name=$name"
exit 0
