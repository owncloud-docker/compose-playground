#!/bin/bash
#
# see also:
#  https://github.com/AARNet/eos-docker/blob/master/README.md
#  https://github.com/owncloud/ocis/blob/master/docs/eos.md#run-it
#  https://golang.org/doc/install
#  https://owncloud.github.io/
#
# 2020-05-11, jw@owncloud.com

if [ -z "$TF_USER" ]; then
  echo "Env variable TF_USER is not set. Please specify what should be shown as the owner of the machine"
  exit 1;
fi
suffix=$(tr -dc 'a-z0-9' < /dev/urandom | head -c 5)

echo "Estimated setup time (when weather is fine): 7 minutes ..."
sleep 2; echo ""; sleep 2; echo ""; sleep 2

name=$TF_USER-aarnet-eos-test-$suffix
bash ./make_machine.sh $name -p git,screen,build-essential,docker.io,docker-compose
ipaddr=$(cd terraform; bin/terraform output ipv4)

if [ -z "$ipaddr" ]; then
  echo "Error: make_machine.sh failed."
  exit 1;
fi

# https://github.com/AARNet/eos-docker/blob/master/README.md#system-requirements

ssh root@$ipaddr sh -x -s <<EOF
  svcfile=/usr/lib/systemd/system/docker.service			# ubuntu-20.04
  test -e \$svcfile || svcfile=/lib/systemd/system/docker.service	# ubuntu-18.04
  sed -i -e 's@\(\[Service\]\)@\1\nMountFlags=shared@' \$svcfile
  grep -C2 MountFlags \$svcfile
  systemctl daemon-reload
  service docker restart

  git clone https://github.com/AARNet/eos-docker.git
  cd eos-docker

  # skip defunct aarnet private repos, as suggested by felix:
  rm -f containers/content/yum/rhel7-dev.repo containers/content/yum/rhscl.repo

  # do not fail filesystem creation, when no tty is connected.
  sed -i -e 's/docker exec -ti /docker exec /' setup

  ./build -t test

  cat <<EOM>/tmp/blurb.txt
---------------------------------------------
# Machine prepared.
#
# This shell is now connected to root@$ipaddr

# follow the instructions at

	https://github.com/AARNet/eos-docker/blob/master/README.md#building-eos-docker-containers

# Enter 'exit' when done.
# Finally, you should destroy the machine e.g. with
        ./destroy_machine.sh $name

---------------------------------------------
EOM
EOF

## FIXME: this is an ugly hack, to get tty allocation working.
## We should push the above as a script to the remote host,
## then start an interactive shell, that runs that script as an rc file, then prompts.

ssh -t root@$ipaddr sh -x -c "echo dummy; cd eos-docker; ./setup -a; cat /tmp/blurb.txt; exec bash"

sleep 2; echo ""; sleep 2
cat <<EOF
---------------------------------------------
# When you no longer need the machine, destroy it with e.g.
        ./destroy_machine.sh $name

---------------------------------------------
EOF
