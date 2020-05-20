#!/bin/bash
#
# see also:
#  https://github.com/AARNet/eos-docker/blob/master/README.md
#  https://github.com/owncloud-docker/compose-playground/tree/master/examples/play-ocis
#  https://github.com/owncloud-docker/compose-playground/tree/eos/examples/eos-docker#eos-docker
#  https://owncloud.github.io/
#
# 2020-05-14, jw@owncloud.com

echo "Estimated setup time (when weather is fine): 6 minutes ..."

source ./make_machine.sh -u ocis-eos-docker-test -p git,screen,docker.io,docker-compose
set -x

if [ -z "$IPADDR" ]; then
  echo "Error: make_machine.sh failed."
  exit 1;
fi

LOAD_SCRIPT <<EOF
  svcfile=/usr/lib/systemd/system/docker.service			# ubuntu-20.04
  test -e \$svcfile || svcfile=/lib/systemd/system/docker.service	# ubuntu-18.04
  sed -i -e 's@\(\[Service\]\)@\1\nMountFlags=shared@' \$svcfile
  grep -C2 MountFlags \$svcfile
  systemctl daemon-reload
  service docker restart

  git clone https://github.com/owncloud-docker/compose-playground.git
  cd compose-playground/examples/eos-docker

  # make sure we build beta4
  # sed -i -e "s/ocis.git/ocis.git -b 1.0.0-beta4/g" containers/Dockertmp.ocis

  ./build -a $IPADDR -t test
  ./setup -a
  # docker-compose up ocis &	# stop and restart, this time with log output visible.

  sleep 5
  cat <<EOM
---------------------------------------------
# Machine prepared.
#
# This shell is now connected to root@$IPADDR

# follow the instructions at

   https://github.com/owncloud-docker/compose-playground/tree/eos/examples/eos-docker#eos-docker

---------------------------------------------
EOM
EOF

RUN_SCRIPT
