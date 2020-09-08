#!/bin/bash
#
# References:
# - https://owncloud.github.io/ocis/eos/
# - https://github.com/owncloud/ocis/blob/master/docker-compose.yml
# - https://owncloud.github.io/ocis/basic-remote-setup/
# - ~/ownCloud/release/ocis/test-2020-07-13.txt
#
# This setup should be greatly simplified by
# - https://github.com/owncloud/ocis/pull/519
# - https://github.com/owncloud/product/issues/165
# - https://jira.owncloud.com/browse/OCIS-376
# - https://jira.owncloud.com/browse/OCIS-392
#
# 2020-08-26, jw@owncloud.com


echo "Estimated setup time (when weather is fine): 7 minutes ..."

if [ -z "$OCIS_VERSION" ]; then
  # export OCIS_VERSION=master
  export OCIS_VERSION=v1.0.0-rc1
  echo "No OCIS_VERSION specified, using $OCIS_VERSION"
  sleep 3
fi

# use a cx31 -- we need more than 20GB disk space.
source ./make_machine.sh -t cx31 -u ocis-${OCIS_VERSION}-eos-compose -p git,vim,screen,docker.io,docker-compose,binutils,ldap-utils
set -x

if [ -z "$IPADDR" ]; then
  echo "Error: make_machine.sh failed."
  exit 1;
fi

version_file=this-is-ocis-$OCIS_VERSION.txt
user_portrait_url=https://upload.wikimedia.org/wikipedia/commons/3/32/Max_Liebermann_Portrait_Albert_Einstein_1925.jpg
user_speech_url=https://upload.wikimedia.org/wikipedia/commons/4/46/03_ALBERT_EINSTEIN.ogg
# eos_home_einstein=/eos/dockertest/reva/users/e/einstein
eos_home_einstein=/eos/dockertest/reva/users/4/4c510ada-c86b-4815-8820-42cdf82c3d51/
eos_uid=20000
eos_gid=30000

LOAD_SCRIPT <<EOF

wait_for_ocis () {
  ## it compiles code upon first start. this can take ca 6 minutes.
  while true; do
    # expect to see "Starting server ... 0.0.0.0:9200" in the logs.
    docker-compose logs --tail=10 ocis
    if [ -n "\$(docker-compose logs ocis | grep 'Starting server' | grep 0.0.0.0:9200)" ]; then
      break
    fi
    echo " ... waiting for 0.0.0.0:9200 ..."
    sleep 15;
  done
}

wait_for_ldap () {
  # expect nslcd is running.
  while test -z "\$(docker-compose exec ocis ps -ef | grep nslcd | grep -v grep)"; do
    echo "waiting for nslcd ...";
    sleep 3;
  done
}

wait_for_eos_fst () {
  # expect (at least) four fst entries.
  while [ "\$(docker-compose exec ocis eos fs ls -m | grep host=fst | wc -l)" -lt 4 ]; do
    echo "waiting for four fst to appear in 'eos fs ls' ..."
    sleep 3;
    docker-compose exec ocis eos fs ls
  done
}

wait_for_eos_health () {
  echo "Expect to see 'online', 'ok', 'fine', 'default.0' here:"
  for i in 1 2 3 4 5 6 7 8 9 0; do
    # immediately after start, default.0 is shown as 0B free and 'full'
    docker-compose exec ocis eos health -a
    if [ -z "\$(docker-compose exec ocis eos health -m | grep status=full)" ]; then
      break	# nothing is full, carry on.
    fi
    sleep 2
  done
}

## get source code
mkdir -p src/github/owncloud
cd       src/github/owncloud
rm -rf ./*
docker images -q | xargs -r docker rmi --force
docker system prune --all --force

git clone https://github.com/owncloud/ocis.git -b $OCIS_VERSION
cd ocis					# there is a new docker-compse file...
## patch the network.

## FIXME: workaround for https://github.com/owncloud/ocis/issues/396
echo >  .env OCIS_DOMAIN=$IPADDR
echo >> .env REVA_FRONTEND_URL=https://$IPADDR:9200
echo >> .env REVA_DATAGATEWAY_URL=https://$IPADDR:9200/data

cat .env >> config/eos-docker.env

## Part two with the bigger hammer: patch the identifier-registration.yaml -- this file is autocreated when ocis starts for the first time.
reg_yml=config/identifier-registration.yaml
if [ ! -f \$reg_yml ]; then
  docker-compose up -d ocis
  wait_for_ocis
  docker-compose stop ocis
  # once only...
  sed -i -e "s@redirect_uris:@redirect_uris:\\n      - https://${IPADDR}:9200/oidc-callback.html@"   \$reg_yml
  sed -i -e "s@origins:@origins:\\n      - https://${IPADDR}:9200\\n      - http://${IPADDR}:9100@" \$reg_yml
fi

## patch in fixes seen in https://github.com/owncloud-docker/compose-playground/pull/44
# sed -i -e "s@KONNECTD_TLS: .*@KONNECTD_TLS: 1@" docker-compose.yml	# not really needed.


##################################################
# Keep the code below in sync with https://github.com/owncloud/ocis/blob/master/docs/eos.md

## EOS | 2020-02-27 20:35:00 +0100
## OCIS can be configured to run on top of eos. While the eos documentation does cover a lot of topics it leaves out
## some details that you may have to either pull from various docker containers, the forums or even the source itself.
##
## This document is a work in progress of the current setup.
## Docker dev environment for eos storage
##
## We begin with the docker-compose.yml found in https://github.com/owncloud/ocis/ and switch it to eos-storage.
## 1. Start eos & ocis containers
##
## Start the eos cluster and ocis via the compose stack.
##
docker-compose up -d

## {{< hint info >}} The first time the ocis container starts up, it will compile ocis from scratch which can take
## a while. To follow progress, run docker-compose logs -f --tail=10 ocis {{< /hint >}}
##
wait_for_ocis

# # mgm-master sometimes explodes during startup...
# if docker-compose ps | grep Exit; then
#   echo "Something exited already, re-trying ..."
#   docker-compose stop
#   docker-compose up -d
#   sleep 10
#   docker-compose ps
#   echo "Please inspect docker-compose logs"
# fi

cat e/master/var/log/eos/mgm/eos.setup.log

## 2. LDAP Support
## Configure the OS to resolve users and groups using ldap
##
docker-compose exec -d ocis /start-ldap

## {{< hint info >}} If the user is not found at first you might need to wait a few more minutes
##  in case the ocis container is still compiling. {{< /hint >}}
##
wait_for_ldap

## Check that the OS in the ocis container can now resolve einstein or the other demo users
##
docker-compose exec ocis id einstein
# uid=20000(einstein) gid=30000(users) groups=30000(users),30001(sailing-lovers),30002(violin-haters),30007(physics-lovers)

## We also need to restart the reva-users service so it picks up the changed environment.
## Without a restart it is not able to resolve users from LDAP.
##
docker-compose exec ocis ./bin/ocis kill reva-users
docker-compose exec ocis ./bin/ocis run reva-users

## 3. Home storage
## Kill the home storage. By default it uses the owncloud storage driver. We need to switch it
##  to the eoshome driver and make it use the storage id of the eos storage provider:
##
docker-compose exec ocis ./bin/ocis kill reva-storage-home
docker-compose exec -e REVA_STORAGE_HOME_DRIVER=eoshome -e REVA_STORAGE_HOME_MOUNT_ID=1284d238-aa92-42ce-bdc4-0b0000009158 ocis ./bin/ocis run reva-storage-home

## 4. Home data provider
## Kill the home data provider. By default it uses the owncloud storage driver. We need to switch it
## to the eoshome driver and make it use the storage id of the eos storage provider:
##
docker-compose exec ocis ./bin/ocis kill reva-storage-home-data
docker-compose exec -e REVA_STORAGE_HOME_DATA_DRIVER=eoshome ocis ./bin/ocis run reva-storage-home-data

## {{< hint info >}} The difference between the home storage and the home data provider are that the
## former is responsible for metadata changes while the latter is responsible for actual data transfer.
## The home storage uses the cs3 api to manage a folder hierarchy, while the home data provider is
## responsible for moving bytes to and from the storage. {{< /hint >}}
##

# FIXME: Workaround for https://github.com/owncloud/ocis/issues/396
# - Uploads fail with "mismatched offset"
# - eos cp fails with "No space left on device"
wait_for_eos_fst
# expect to see stat.active=online four times!
while [ "\$(docker-compose exec ocis eos fs ls -m | grep stat.active=online | wc -l)" -lt 4 ]; do
  sleep 5
  # docker-compose exec ocis eos -r 0 0 space set default on	# same as below?
  docker-compose exec mgm-master eos space set default on
  sleep 5
  docker-compose exec ocis eos fs ls
done
wait_for_eos_health

# show some nice stats
docker-compose exec ocis eos fs ls --io | sed -e 's/  / /g'
docker-compose exec ocis eos space ls --io


if [ -f ~/make_machine.bashrc ]; then
  echo >  $version_file '\`\`\`'
  echo >> $version_file "OCIS_VERSION:         $OCIS_VERSION"
  echo >> $version_file "ocis --version:       \$(docker-compose exec ocis bin/ocis --version)"
  echo >> $version_file "git log:              \$(git log --decorate=full | head -1)"
  echo >> $version_file "eos --version:        \$(docker-compose exec ocis eos --version | head -1)"
  echo >> $version_file "xrootd -v:            \$(docker-compose exec ocis /opt/eos/xrootd/bin/xrootd -v)"
  # echo >> $version_file "rpm -q quarkdb:       \$(docker-compose exec quark-3 rpm -q quarkdb)"
  # echo >> $version_file "rpm -q zeromq:        \$(docker-compose exec quark-3 rpm -q zeromq)"
  # echo >> $version_file "rpm -q eos-protobuf3: \$(docker-compose exec quark-3 rpm -q eos-protobuf3)"
  echo >> $version_file "bin/ocis contains:"
  strings bin/ocis | grep 'owncloud/ocis-.*@v' | sed -e 's@.*/owncloud/@\towncloud/@' -e 's%\(@v[^/]*\).*%\1%' | sort -u >> $version_file

  # make some files appear within the owncloud
  echo '\`\`\`' > ~/make_machine.bashrc.md
  cat ~/make_machine.bashrc >>  ~/make_machine.bashrc.md
  docker cp ~/make_machine.bashrc.md ocis:/
  docker cp $version_file            ocis:/
  docker-compose exec ocis eos -r 0 0               mkdir -p $eos_home_einstein
  docker-compose exec ocis eos -r 0 0               chown $eos_uid:$eos_gid $eos_home_einstein
  docker-compose exec ocis eos -r $eos_uid $eos_gid mkdir $eos_home_einstein/init
  docker-compose exec ocis eos -r $eos_uid $eos_gid cp /$version_file /make_machine.bashrc.md $eos_home_einstein/init/

  docker-compose exec ocis curl $user_portrait_url -so /tmp/Portrait.jpg
  docker-compose exec ocis curl $user_speech_url   -so /tmp/Speech.ogg
  docker-compose exec ocis eos -r $eos_uid $eos_gid cp /tmp/Speech.ogg /tmp/Portrait.jpg $eos_home_einstein/
fi


echo "Now log in with user einstein at https://${IPADDR}:9200"
docker-compose exec ocis eos newfind /eos
cat e/master/var/log/eos/mgm/eos.setup.log

uptime
sleep 5
cat <<EOM

## To list the globally trashed files (all users):
# docker-compose exec mgm-master eos -r 0 0 recycle ls -g
#
# docker-compose exec mgm-master eos space config default space.policy.recycle=on
# docker-compose exec mgm-master eos recycle config --add-bin /eos/dockertest/reva/users
# docker-compose exec mgm-master recycle config --size 1G
# then delete and list again
#
# maybe docker-compose exec mgm-master eos space config default space.policy.recycle=on
# is not necessary
# but it alone did not enable a trash
# i had to configure a size before it worked
# otherwise i would get
#
# ocis          | 2020-08-27T10:50:11Z ERR reva/internal/grpc/services/storageprovider/storageprovider.go:410 > error deleting file: path:"/home/ownCloud-osx10.11-2.6.3.13765.pkg.sig"  error="eosclient: error while executing command: exit status 19" pkg=rgrpc service=reva traceid=dd9445674487c90417365538b853d766
# in the logs

---------------------------------------------
# This shell is now connected to root@$IPADDR
# Connect your browser or client to

   https://$IPADDR:9200

   also check eos fs status again...

# To restart completely from scratch

   cd /root/src/github/owncloud/ocis
   docker-compose down -v
   make clean
   docker-compose up -d 	# CAUTION: this also switches to /var/tmp/reva/data storage.

---------------------------------------------
EOM
EOF

RUN_SCRIPT
