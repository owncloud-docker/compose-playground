#!/bin/bash
#
# References:
# - https://owncloud.github.io/ocis/eos/
# - https://owncloud.github.io/ocis/basic-remote-setup/
# - ~/ownCloud/release/ocis/test-2020-07-13.txt
#
# 2020-07-15, jw@owncloud.com

echo "Estimated setup time (when weather is fine): 7 minutes ..."

if [ -z "$OCIS_VERSION" ]; then
  # export OCIS_VERSION=master
  export OCIS_VERSION=v1.0.0-beta8
  echo "No OCIS_VERSION specified, using $OCIS_VERSION"
  sleep 3
fi

source ./make_machine.sh -u ocis-${OCIS_VERSION}-eos-compose -p git,vim,screen,docker.io,docker-compose
set -x

if [ -z "$IPADDR" ]; then
  echo "Error: make_machine.sh failed."
  exit 1;
fi

#echo OCIS_DOMAIN=localhost > .env

LOAD_SCRIPT <<EOF

wait_for_ocis () {
  ## it compiles code upon first start. this can take ca 6 minutes.
  while true; do
    # expect to see "Starting server ... 0.0.0.0:9200" in the logs.
    docker-compose logs ocis | tail -10
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


## follow https://owncloud.github.io/ocis/eos/
docker-compose up -d	# felix did instead only "docker-compose up -d ocis"
wait_for_ocis

# mgm-master sometimes explodes during startup...
if docker-compose ps | grep Exit; then
  echo "Something exited already, re-trying ..."
  docker-compose stop
  docker-compose up -d
  sleep 10
  docker-compose ps
  echo "Please inspect docker-compose logs"
fi

cat e/master/var/log/eos/mgm/eos.setup.log

## enable our mini-builtin-ldap IDP
docker-compose exec ocis id einstein
#  id: einstein: no such user
docker-compose exec -d ocis /start-ldap
wait_for_ldap

docker-compose exec ocis id einstein
# uid=20000(einstein) gid=30000(users) groups=30000(users),30001(sailing-lovers),30002(violin-haters),30007(physics-lovers)
docker-compose exec ocis ./bin/ocis kill reva-users
docker-compose exec ocis ./bin/ocis run reva-users


## migrate from local 'owncloud' storage to 'eoshome' storage
docker-compose exec ocis ./bin/ocis kill reva-storage-home
docker-compose exec -e REVA_STORAGE_EOS_LAYOUT="{{substr 0 1 .Username}}/{{.Username}}" -e REVA_STORAGE_HOME_DRIVER=eoshome ocis ./bin/ocis run reva-storage-home

docker-compose exec ocis ./bin/ocis kill reva-storage-home-data
docker-compose exec -e REVA_STORAGE_EOS_LAYOUT="{{substr 0 1 .Username}}/{{.Username}}" -e REVA_STORAGE_HOME_DATA_DRIVER=eoshome ocis ./bin/ocis run reva-storage-home-data

docker-compose exec ocis ./bin/ocis kill reva-frontend
docker-compose exec -e DAV_FILES_NAMESPACE="/eos/" ocis ./bin/ocis run reva-frontend

du -sh e/*
# 17M     e/disks
# 71M     e/master
# 146M    e/quark-1
# 146M    e/quark-2
# 146M    e/quark-3

#### TRY reva user restart very late.
docker-compose exec ocis ./bin/ocis kill reva-users
docker-compose exec ocis ./bin/ocis run reva-users

for d in ocis mq-master quark-1 quark-2 quark-3 fst mgm-master; do
  docker-compose exec \$d sh -c "echo 'einstein:x:20000:30000:Albert Einstein:/:/sbin/nologin' >> /etc/passwd";
done


# Workaround for: https://github.com/owncloud/ocis/issues/396
# - Uploads fail with "mismatched offset"
# - eos cp fails with "No space left on device"
wait_for_eos_fst
# expect to see stat.active=online four times!
while [ "\$(docker-compose exec ocis eos fs ls -m | grep stat.active=online | wc -l)" -lt 4 ]; do
  sleep 5
  docker-compose exec ocis eos -r 0 0 space set default on
  sleep 5
  docker-compose exec ocis eos fs ls
done
wait_for_eos_health


  if [ -f ~/make_machine.bashrc ]; then
    # make some files appear within the owncloud
    echo '```' > ~/make_machine.bashrc.md
    cat ~/make_machine.bashrc >>  ~/make_machine.bashrc.md
    docker cp ~/make_machine.bashrc.md ocis:/
    docker-compose exec ocis eos -r 0 0 mkdir -p $eos_home
    docker-compose exec ocis eos -r 0 0 chown $eos_uid:$eos_gid $eos_home
    docker-compose exec ocis eos -r $eos_uid $eos_gid mkdir $eos_home/init
    docker-compose exec ocis eos -r $eos_uid $eos_gid cp /make_machine.bashrc.md $eos_home/init/
    docker-compose exec ocis eos -r $eos_uid $eos_gid touch $eos_home/init/this-is-ocis-$OCIS_VERSION
    docker-compose exec ocis curl $user_portrait_url -so Portrait.jpg
    docker-compose exec ocis eos -r $eos_uid $eos_gid cp Portrait.jpg $eos_home/
  fi


echo "Now log in with user einstein at https://${IPADDR}:9200"
docker-compose exec ocis eos newfind /eos
cat e/master/var/log/eos/mgm/eos.setup.log

uptime
sleep 5
cat <<EOM
---------------------------------------------
# This shell is now connected to root@$IPADDR
# Connect your browser or client to

   https://$IPADDR:9200

   also check eos fs status again...

# if the client fails to upload with internal error 500, try

   docker-compose down; docker-compose up -d

---------------------------------------------
EOM
EOF

RUN_SCRIPT
