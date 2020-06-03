#!/bin/bash
#
#  https://github.com/owncloud-docker/compose-playground/blob/master/examples/eos-compose/README.md
#  https://etherpad.owncloud.com/p/fixocis
#  https://owncloud.github.io/
#
# 2020-05-24, jw@owncloud.com

echo "Estimated setup time (when weather is fine): 5 minutes ..."

source ./make_machine.sh -u ocis-eos-compose-test -p git,screen,docker.io,docker-compose
set -x

if [ -z "$IPADDR" ]; then
  echo "Error: make_machine.sh failed."
  exit 1;
fi

if [ -z "$OCIS_VERSION" ]; then
  export OCIS_VERSION=master
  # export OCIS_VERSION=v1.0.0-beta4
  echo "No OCIS_VERSION specified, using $OCIS_VERSION"
  sleep 3
fi

eos_home=/eos/dockertest/reva/users/e/einstein
eos_uid=20000
eos_gid=30000

LOAD_SCRIPT <<EOF
  svcfile=/usr/lib/systemd/system/docker.service			# ubuntu-20.04
  test -e \$svcfile || svcfile=/lib/systemd/system/docker.service	# ubuntu-18.04
  sed -i -e 's@\(\[Service\]\)@\1\nMountFlags=shared@' \$svcfile
  grep -C2 MountFlags \$svcfile
  systemctl daemon-reload
  service docker restart

  git clone https://github.com/owncloud-docker/compose-playground.git
  cd compose-playground/examples/eos-compose

  ## make sure we build beta4. CAUTION: if the selected tag or branch does not exist, we get this error:
  ##  Pulling ocis (cloudservices/eos/eos-citrine-ocis:test)...
  ##  ERROR: The image for the service you're trying to recreate has been removed
  sed -i -e "s/^ARG BRANCH=.*$/ARG BRANCH=$OCIS_VERSION/" eos-ocis/Dockerfile

  set -x
  ./build
  ./setup
  if [ "\$(grep OCIS_DOMAIN= .env)" != "OCIS_DOMAIN=$IPADDR" ]; then
    echo "ERROR: ./setup got the IP-ADDR wrong"
    cat .env
    echo "... fixing it to $IPADDR"

    echo OCIS_DOMAIN=$IPADDR >> .env
    sleep 10
  fi

  docker-compose up -d

  sleep 5
  if [ -f ~/make_machine.bashrc ]; then
    # make that file appear within the owncloud
    # Try this from within mgm-master, while debugging ocis
    docker cp ~/make_machine.bashrc ocis:/
    # docker exec ocis eos -r 0 0 mkdir -p $eos_home/init
    # docker exec ocis eos -r 0 0 chown -r $eos_uid:$eos_gid $eos_home
    # docker exec ocis eos -r $eos_uid $eos_gid cp make_machine.bashrc $eos_home/init
    # docker exec ocis eos -r $eos_uid $eos_gid touch $eos_home/init/this-is-ocis-$OCIS_VERSION
  fi

  uptime
  sleep 5
  cat <<EOM
---------------------------------------------
# Machine prepared.
#
# This shell is now connected to root@$IPADDR
# Connect your browser or client to

   https://$IPADDR:9200

# Start ocis with

   docker-compose up ocis

# View the logs with

   docker-compose logs -f
   ssh root@$IPADDR sh -c "echo; cd compose-playground/examples/eos-compose; docker-compose logs -f"

# Tinker with the ocis container:

   docker-compose exec ocis bash
   ssh root@$IPADDR sh -c "echo; cd compose-playground/examples/eos-compose; docker-compose exec ocis bash"

---------------------------------------------
EOM
EOF

RUN_SCRIPT
