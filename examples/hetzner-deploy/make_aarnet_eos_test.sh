#!/bin/bash
#
# see also:
#  https://github.com/AARNet/eos-docker/blob/master/README.md
#  https://github.com/owncloud/ocis/blob/master/docs/eos.md#run-it
#  https://golang.org/doc/install
#  https://owncloud.github.io/
#
# 2020-05-11, jw@owncloud.com

echo "Estimated setup time (when weather is fine): 7 minutes ..."

source ./make_machine.sh -u aarnet-eos-test -p git,screen,build-essential,docker.io,docker-compose

LOAD_SCRIPT << EOF
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
  ./setup -a

  cat <<EOM
---------------------------------------------
# Machine prepared.
#
# This shell is now connected to root@$IPADDR

# follow the instructions at

	https://github.com/AARNet/eos-docker/blob/master/README.md#building-eos-docker-containers
---------------------------------------------
EOM
EOF

RUN_SCRIPT
