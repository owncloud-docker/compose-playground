#!/bin/bash
#
#  https://github.com/owncloud-docker/compose-playground/blob/master/examples/eos-compose/README.md
#  https://etherpad.owncloud.com/p/fixocis
#  https://owncloud.github.io/
#
# 2020-05-24, jw@owncloud.com

echo "Estimated setup time (when weather is fine): 7 minutes ..."

## CAUTION: if the selected tag or branch does not exist, we get this error:
##  Pulling ocis (cloudservices/eos/eos-citrine-ocis:test)...
##  ERROR: The image for the service you're trying to recreate has been removed

if [ -z "$OCIS_VERSION" ]; then
  export OCIS_VERSION=master
  # export OCIS_VERSION=v1.0.0-beta5
  echo "No OCIS_VERSION specified, using $OCIS_VERSION"
  sleep 3
fi

source ./make_machine.sh -u ocis-${OCIS_VERSION}-eos-compose -p git,screen,docker.io,docker-compose
set -x

if [ -z "$IPADDR" ]; then
  echo "Error: make_machine.sh failed."
  exit 1;
fi

user_portrait_url=https://upload.wikimedia.org/wikipedia/commons/3/32/Max_Liebermann_Portrait_Albert_Einstein_1925.jpg
eos_home=/eos/dockertest/reva/users/e/einstein
eos_uid=20000
eos_gid=30000

#  svcfile=/usr/lib/systemd/system/docker.service			# ubuntu-20.04
#  test -e \$svcfile || svcfile=/lib/systemd/system/docker.service	# ubuntu-18.04
#  sed -i -e 's@\(\[Service\]\)@\1\nMountFlags=shared@' \$svcfile
#  grep -C2 MountFlags \$svcfile
#  systemctl daemon-reload
#  service docker restart

LOAD_SCRIPT <<EOF
  git clone https://github.com/owncloud-docker/compose-playground.git
  cd compose-playground/examples/eos-compose

  sed -i -e "s/^ARG BRANCH=.*$/ARG BRANCH=$OCIS_VERSION/" eos-ocis/Dockerfile

  ./build
  echo OCIS_DOMAIN=$IPADDR > .env

  docker-compose up -d

  sleep 5
  if [ -f ~/make_machine.bashrc ]; then
    # make some files appear within the owncloud
    docker cp ~/make_machine.bashrc ocis:/
    docker exec ocis eos -r $eos_uid $eos_gid mkdir -p $eos_home/init
    docker exec ocis eos -r $eos_uid $eos_gid cp /make_machine.bashrc $eos_home/init
    docker exec ocis eos -r $eos_uid $eos_gid touch $eos_home/init/this-is-ocis-$OCIS_VERSION
    docker exec ocis curl $user_portrait_url -so Portrait.jpg
    docker exec ocis eos -r $eos_uid $eos_gid cp Portrait.jpg $eos_home/
  fi

  uptime
  sleep 5
  cat <<EOM
---------------------------------------------
# This shell is now connected to root@$IPADDR
# Connect your browser or client to

   https://$IPADDR:9200

---------------------------------------------
EOM
EOF

RUN_SCRIPT
