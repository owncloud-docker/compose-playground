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
  export OCIS_VERSION=v1.0.0-beta9
  echo "No OCIS_VERSION specified, using $OCIS_VERSION"
  sleep 3
fi

source ./make_machine.sh -t cx31 -u ocis-${OCIS_VERSION}-eos-compose -p git,vim,screen,docker.io,docker-compose,binutils
set -x

if [ -z "$IPADDR" ]; then
  echo "Error: make_machine.sh failed."
  exit 1;
fi

version_file=this-is-ocis-$OCIS_VERSION.txt
user_portrait_url=https://upload.wikimedia.org/wikipedia/commons/3/32/Max_Liebermann_Portrait_Albert_Einstein_1925.jpg
user_speech_url=https://upload.wikimedia.org/wikipedia/commons/4/46/03_ALBERT_EINSTEIN.ogg
eos_home=/eos/dockertest/reva/users/e/einstein
eos_uid=20000
eos_gid=30000

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
sed -i -e "s@REVA_OIDC_ISSUER:@PROXY_OIDC_ISSUER: https://\\\${OCIS_DOMAIN:-localhost}:9200\\n      REVA_OIDC_ISSUER:@" docker-compose.yml


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

#### TRY reva user restart very late.
docker-compose exec ocis ./bin/ocis kill reva-users
docker-compose exec ocis ./bin/ocis run reva-users

# FIXME: Workaround for https://github.com/owncloud/ocis/issues/308
for d in ocis mq-master quark-1 quark-2 quark-3 fst mgm-master; do
  docker-compose exec \$d sh -c "echo >> /etc/passwd 'einstein:x:20000:30000:Albert Einstein:/:/sbin/nologin'";
  docker-compose exec \$d sh -c "echo >> /etc/passwd 'marie:x:20001:30000:Marie Curie:/:/sbin/nologin'";
  docker-compose exec \$d sh -c "echo >> /etc/passwd 'feynman:x:20002:30000:Richard Feynman:/:/sbin/nologin'";
done


# FIXME: Workaround for https://github.com/owncloud/ocis/issues/396
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
  docker-compose exec ocis eos -r 0 0               mkdir -p $eos_home
  docker-compose exec ocis eos -r 0 0               chown $eos_uid:$eos_gid $eos_home
  docker-compose exec ocis eos -r $eos_uid $eos_gid mkdir $eos_home/init
  docker-compose exec ocis eos -r $eos_uid $eos_gid cp /$version_file /make_machine.bashrc.md $eos_home/init/

  docker-compose exec ocis curl $user_portrait_url -so /tmp/Portrait.jpg
  docker-compose exec ocis curl $user_speech_url   -so /tmp/Speech.ogg
  docker-compose exec ocis eos -r $eos_uid $eos_gid cp /tmp/Speech.ogg /tmp/Portrait.jpg $eos_home/
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

   docker-compose down; docker-compose up -d 	# CAUTION: this also switches to /var/tmp/reva/data storage.

---------------------------------------------
EOM
EOF

RUN_SCRIPT
