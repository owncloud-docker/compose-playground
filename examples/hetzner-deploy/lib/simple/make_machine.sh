#! /bin/sh
version=0.5

exec 3>&1 1>&2	# all output goes to stderr.
set -e

extra_pkg=""
do_login=false
NAME=
# getopts cannot do long names and needs more code.
while [ "$#" -gt 0 ]; do
  case "$1" in
    -p|--packages) extra_pkg="$2"; shift ;;
    -l|--login) do_login=true ;;
    -s|--ssh-key-names) shift ;;
    -d|--datacenter) shift ;;
    -i|--image) shift ;;
    -t|--type) shift ;;
    -u|--unique) ;;
    -h|--help) NAME=-h ;;
    -*) echo "Unknown option '$1'. Try --help"; exit 1 ;;
    *) NAME="$1" ;;
  esac
  shift
done

if [ "$NAME" = '-h' ]; then
  cat <<EOF
  $0 V$version

  Usage:
    export OC_DEPLOY_ADDR=localhost
    $0 [OPTIONS] (MACHINE_NAME)
    \$(bash ./make_machine.sh ...)
    source ./make_machine.sh ...

  Where options are:

    -p|--packages ...       comma-separated list of linux packages to install
    -l|--login ...	    open an interactive root shell when done

  Ignored options:
    -u|--unique
    -i|--image
    -t|--type
    -d|--datacenter
    -s|--ssh-key-names

  The MACHINE_NAME is unused.

  "export IPADDR=... NAME=..." is printed on stdout describing the deploy target.
EOF
  test ! -t 3 && echo 1>&3 "export IPADDR= NAME=-h"
  exit 1
fi

# convert comma-separated to whitespace separated:
extra_pkg=$(echo $extra_pkg | tr , ' ')

if [ -z "$NAME" ]; then
  NAME="$(echo "$OC_DEPLOY_ADDR" | tr ._ -)"
fi

THERE="ssh -t root@$OC_DEPLOY_ADDR"
IPADDR=$OC_DEPLOY_ADDR
if hostname -I | grep -q -w $OC_DEPLOY_ADDR; then
  # we were called with an IP-address, that is actually our own address
  echo "$OC_DEPLOY_ADDR found locally. switching to OC_DEPLOY_ADDR=localhost"
  OC_DEPLOY_ADDR=localhost
fi
if [ "$OC_DEPLOY_ADDR" = localhost -o "$OC_DEPLOY_ADDR" = 127.0.0.1 ]; then
  THERE=sudo
  # IPADDR is used by the scripts to configure remote use. localhost won't do.
  #  Substitute the ip address associated with our first default route.
  if [ "$IPADDR" = localhost -o "$IPADDR" = 127.0.0.1 ]; then
    # we were called with OC_DEPLOY_ADDR=localhost, that is fine, but we want to know a real IP-Address too.
    IPADDR=$(ip route show default | head -1 | sed -e 's/.* src //' -e 's/ .*$//')
  fi
fi

if [ -n "$extra_pkg" ]; then
  . /etc/os-release
  case "$ID" in
    linuxmint|ubuntu|debian)
      $THERE apt-get update -y
      echo "+ $THERE apt-get install -y $extra_pkg"
      $THERE apt-get install -y $extra_pkg
	;;
    fedora|centos)
        echo "+ $THERE yum install -y $extra_pkg"
        $THERE yum install -y $extra_pkg
	;;
    *) echo "platform installer not implemented for $ID. Skipping package installation of $extra_pkg"
        ;;
  esac
fi

if [ "$do_login" = true ]; then
  $THERE bash	# sudo or ssh ...
fi

echo 1>&3 "export IPADDR=$IPADDR NAME=$NAME"
exit 0
