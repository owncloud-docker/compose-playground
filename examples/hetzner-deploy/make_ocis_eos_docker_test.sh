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

ocis_version=v1.0.0-beta4
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
  cd compose-playground/examples/eos-docker

  ## make sure we build beta4. CAUTION: if the selected tag or branch does not exist, we get this error:
  ##  Pulling ocis (cloudservices/eos/eos-citrine-ocis:test)...
  ##  ERROR: The image for the service you're trying to recreate has been removed
  sed -i -e "s/ocis\.git.*$/ocis.git -b $ocis_version/g" containers/Dockertmp.ocis

  ./build -a $IPADDR -t test
  ./setup -a

  if [ -f ~/make_machine.bashrc ]; then
    # make that file appear within the owncloud
    docker cp ~/make_machine.bashrc ocis:/
    docker exec ocis eos -r 0 0 mkdir -p $eos_home/init
    docker exec ocis eos -r 0 0 chown -r $eos_uid:$eos_gid $eos_home
    docker exec ocis eos -r $eos_uid $eos_gid cp make_machine.bashrc $eos_home/init
    docker exec ocis eos -r $eos_uid $eos_gid touch $eos_home/init/this-is-ocis-$ocis_version
  fi

  sleep 5
  cat <<EOM
---------------------------------------------
# Machine prepared.
#
# This shell is now connected to root@$IPADDR
# Connect your browser or client to

   https://$IPADDR:9200

# View the logs with

   ssh root@$IPADDR sh -c "echo; cd compose-playground/examples/eos-docker; docker-compose logs -f"

# Follow the instructions at

   https://github.com/owncloud-docker/compose-playground/tree/eos/examples/eos-docker#eos-docker

---------------------------------------------
EOM
EOF

RUN_SCRIPT
