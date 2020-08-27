#! /bin/bash
# Factory switcher to choose between hcloud_tf, hcloud_py, and simple.

libdir=$(dirname $0)/lib
test -z "$HCLOUD_TOKEN" && export HCLOUD_TOKEN=$TF_VAR_hcloud_token
test -z "$OC_DEPLOY" -a -n "$OC_DEPLOY_ADDR" && OC_DEPLOY=simple
if [ -z "$OC_DEPLOY" -a -n "$HCLOUD_TOKEN" ]; then
  test -z "$(python3 -c 'import hcloud' 2>&1)" && OC_DEPLOY=hcloud_py || OC_DEPLOY=hcloud_tf
fi
test -z "$OC_DEPLOY" -o ! -d $libdir/$OC_DEPLOY && { echo 1>&2 "define HCLOUD_TOKEN or set OC_DEPLOY to one of $(ls -m $libdir)"; exit 1; }

test "$OC_DEPLOY" = hcloud_py && suf=py || suf=sh
echo 1>&2 "Using OC_DEPLOY=$OC_DEPLOY ..."
NAME=
IPADDR=
$($libdir/$OC_DEPLOY/make_machine.$suf "$@")

if [ -z "$IPADDR" ]; then
  if [ "$NAME" = '-h' ]; then		# usage was printed.
    cat <<EOF

Additonal environment variables:

  OC_DEPLOY_ADDR=localhost		Deploy at localhost. Skip machine creation. Will use 'sudo'.
  OC_DEPLOY_ADDR=XX.XX.XX.XX		Deploy at existing IPv4-address. Skip machine creation. Will use 'ssh root@...'
  OC_DEPLOY_ADDR=			(Empty or undefined). Create machine at Hetzner cloud.
EOF
  else
    echo "Error: make_machine.sh failed."
  fi
  exit 1;
fi

scriptfile=./tmpscript$$.sh
function LOAD_SCRIPT {
  cat $1 > $scriptfile
}

function RUN_SCRIPT {
  if [ "$OC_DEPLOY_ADDR" = localhost -o "$OC_DEPLOY_ADDR" = 127.0.0.1 ]; then
    sudo bash $scriptfile
  else
    echo 'set +x' >> $scriptfile
    echo '. ~/.bashrc' >> $scriptfile
    scp -q $scriptfile root@$IPADDR:make_machine.bashrc
    ssh -t root@$IPADDR bash --rcfile make_machine.bashrc
  fi
  set +x
  rm -f $scriptfile

  if [ "$OC_DEPLOY" != 'simple' ]; then
    cat <<EOF
---------------------------------------------
# Log into the machine with

	ssh root@$IPADDR

# When you no longer need the machine, destroy it with e.g.
        ./destroy_machine.sh $NAME

---------------------------------------------
EOF
  fi
}

# not used normally, but fulfill what the usage says:
echo export IPADDR=$IPADDR NAME=$NAME
