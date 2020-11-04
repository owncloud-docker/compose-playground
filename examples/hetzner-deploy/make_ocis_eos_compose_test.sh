#!/bin/bash
#
# References:
# - https://owncloud.github.io/ocis/eos/
# - https://github.com/owncloud/ocis/blob/master/ocis/docker-compose-eos-test.yml
# - ~/ownCloud/release/ocis/test-2020-07-13.txt
#
# This setup should be greatly simplified by
# - https://github.com/owncloud/ocis/pull/519
# - https://github.com/owncloud/product/issues/165
# - https://jira.owncloud.com/browse/OCIS-376
# - https://jira.owncloud.com/browse/OCIS-392
#
# 2020-08-26, jw@owncloud.com
# 2020-09-17, jw@owncloud.com
# 2020-10-30, jw@owncloud.com
# 2020-11-05, jw@owncloud.com

echo "Estimated setup time (when weather is fine): 10 minutes ..."

compose_yml=docker-compose-eos-test.yml
ocis_bin=/usr/local/bin/ocis

if [ -z "$OCIS_VERSION" ]; then
  # export OCIS_VERSION=master
  export OCIS_VERSION=v1.0.0-rc3
  echo "No OCIS_VERSION specified, using $OCIS_VERSION"
  sleep 3
fi

# use a cx31 -- we need more than 40GB disk space.
source ./make_machine.sh -t cx31 -u ocis-${OCIS_VERSION}-eos -p git,vim,screen,docker.io,docker-compose,binutils,ldap-utils
set -x

if [ -z "$IPADDR" ]; then
  echo "Error: make_machine.sh failed."
  exit 1;
fi

version_file=this-is-ocis-$OCIS_VERSION.txt
user_portrait_url=https://upload.wikimedia.org/wikipedia/commons/3/32/Max_Liebermann_Portrait_Albert_Einstein_1925.jpg
user_speech_url=https://upload.wikimedia.org/wikipedia/commons/4/46/03_ALBERT_EINSTEIN.ogg
eos_home_einstein=/eos/dockertest/reva/users/4/4c510ada-c86b-4815-8820-42cdf82c3d51/
eos_uid=20000
eos_gid=30000

LOAD_SCRIPT <<EOF

wait_for_ocis () {
  ## it compiles code upon first start. this can take ca 6 minutes.
  while true; do
    # expect to see "Starting server ... 0.0.0.0:9200" in the logs.
    docker-compose -f $compose_yml logs --tail=10 ocis
    if [ -n "\$(docker-compose -f $compose_yml logs ocis | grep 'Starting server' | grep 0.0.0.0:9200)" ]; then
      break
    fi
    echo " ... waiting for 0.0.0.0:9200 ..."
    sleep 15;
  done
}

wait_for_ldap () {
  # expect nslcd is running.
  while test -z "\$(docker-compose -f $compose_yml exec ocis ps -ef | grep nslcd | grep -v grep)"; do
    echo "waiting for nslcd ...";
    sleep 3;
  done
}

wait_for_eos_fst () {
  # expect (at least) four fst entries.
  while [ "\$(docker-compose -f $compose_yml exec ocis eos fs ls -m | grep host=fst | wc -l)" -lt 4 ]; do
    echo "waiting for four fst to appear in 'eos fs ls' ..."
    sleep 3;
    docker-compose -f $compose_yml exec ocis eos fs ls
  done
}

wait_for_eos_health () {
  echo "Expect to see status 'online', 'ok', 'fine', 'default.0' here:"
  for i in 1 2 3 4 5 6 7 8 9 0; do
    # immediately after start, default.0 is shown as 0B free and 'full'
    docker-compose -f $compose_yml exec ocis eos health -a
    if [ -z "\$(docker-compose -f $compose_yml exec ocis eos health -m | grep status=full)" ]; then
      break	# nothing is full, carry on.
    fi
    sleep 2
  done
}

echo -e "#! /bin/sh\ncd ~/ocis/ocis\ndocker-compose -f $compose_yml logs -f --tail=10 ocis" > /usr/local/bin/show_logs
chmod a+x /usr/local/bin/show_logs

cd ~
rm -rf ./ocis
docker images -q | xargs -r docker rmi --force
docker system prune --all --force
docker volume prune --force


git clone https://github.com/owncloud/ocis.git -b $OCIS_VERSION
cd ocis/ocis

## FIXME website is blank without this.
##
## workaround for https://jira.owncloud.com/browse/OCIS-489
# 2020-10-29: should be fixed by https://github.com/owncloud/ocis-phoenix/pull/83
##
# config_json=config/config.json
# cat <<END_CONFIG_JSON > \$config_json
# {
#   "server": "https://${IPADDR}:9200",
#   "theme": "owncloud",
#   "version": "0.1.0",
#   "openIdConnect": {
#     "metadata_url": "https://${IPADDR}:9200/.well-known/openid-configuration",
#     "authority": "https://${IPADDR}:9200",
#     "client_id": "phoenix",
#     "response_type": "code",
#     "scope": "openid profile email"
#   },
#   "apps": [
#     "files",
#     "draw-io",
#     "pdf-viewer",
#     "markdown-editor",
#     "media-viewer"
#   ],
#   "external_apps": [
#     {
#       "id": "accounts",
#       "path": "https://${IPADDR}:9200/accounts.js"
#     },
#     {
#       "id": "settings",
#       "path": "https://${IPADDR}:9200/settings.js"
#     }
#   ],
#   "options": {
#     "hideSearchBar": true
#   }
# }
# END_CONFIG_JSON

#################################################
## commented out, to see if still neeeded:
#
# ## FIXME: workaround for https://github.com/owncloud/ocis/issues/396
echo >  .env OCIS_DOMAIN=$IPADDR
echo >> .env REVA_FRONTEND_URL=https://$IPADDR:9200
echo >> .env REVA_DATAGATEWAY_URL=https://$IPADDR:9200/data
# echo >> .env PHOENIX_WEB_CONFIG=/ocis/\$config_json
# 
cat .env >> config/eos-docker.env

#################################################
## FIXME: we still see localhost only with 1.0.0-rc3 - this hack is still needed.
## it is no longer auto-created, but we have multiple candidates around:
# for reg_yml in ../konnectd/*/identifier-registration.yaml ; do
#   sed -i -e "s@://localhost:9@://$IPADDR:9@" $reg_yml
# done


# ## Part two with the bigger hammer: patch the identifier-registration.yaml -- this file is autocreated when ocis starts for the first time.
# # the original file comes from https://github.com/owncloud/ocis-konnectd/blob/master/assets/identifier-registration.yaml
# reg_yml=config/identifier-registration.yaml
# if [ ! -f \$reg_yml ]; then
#   docker-compose -f $compose_yml up -d ocis
#   wait_for_ocis
#   docker-compose -f $compose_yml stop ocis
#   # once only... and only for phoenix!
#   sed -i -e "s@^\\s*- https://localhost:9200/\\\$@      - https://${IPADDR}:9200/oidc-callback.html\\n      - https://${IPADDR}:9200/oidc-silent-callback.html\\n      - https://${IPADDR}:9200/\\n      - https://localhost:9200/@" \$reg_yml
#   sed -i -e "s@^\s*- https://localhost:9200\\\$@      - https://${IPADDR}:9200\\n      - http://${IPADDR}:9100\\n      - https://localhost:9200@" \$reg_yml
# fi





##################################################
# Keep the code below in sync with https://github.com/owncloud/ocis/blob/master/docs/eos.md

## 1. Start eos & ocis containers
##
## Start the eos cluster and ocis via the compose stack.
##
docker-compose -f $compose_yml up -d
##
wait_for_ocis


## 2. LDAP Support
## Configure the OS to resolve users and groups using ldap
##
docker-compose -f $compose_yml exec -d ocis /start-ldap

## {{< hint info >}} If the user is not found at first you might need to wait a few more minutes
##  in case the ocis container is still compiling. {{< /hint >}}
##
wait_for_ldap

## Check that the OS in the ocis container can now resolve einstein or the other demo users
##
docker-compose -f $compose_yml exec ocis id einstein
# uid=20000(einstein) gid=30000(users) groups=30000(users),30001(sailing-lovers),30002(violin-haters),30007(physics-lovers)

## We also need to restart the storage-users service so it picks up the changed environment.
## Without a restart it is not able to resolve users from LDAP.
##
docker-compose -f $compose_yml exec ocis $ocis_bin kill storage-users
docker-compose -f $compose_yml exec ocis $ocis_bin run storage-users


## FIXME: duplicate STORAGE_STORAGE and sotrage-storage here? This is
##        as documented in https://owncloud.github.io/ocis/eos/ but looks like a copy/past glitch???
#
## 3. Home storage
## Kill the home storage. By default it uses the owncloud storage driver. We need to switch it
##  to the eoshome driver and make it use the storage id of the eos storage provider:
##
docker-compose -f $compose_yml exec ocis $ocis_bin kill storage-storage-home
docker-compose -f $compose_yml exec -e STORAGE_STORAGE_HOME_DRIVER=eoshome -e STORAGE_STORAGE_HOME_MOUNT_ID=1284d238-aa92-42ce-bdc4-0b0000009158 ocis $ocis_bin run storage-storage-home


## 4. Home data provider
## Kill the home data provider. By default it uses the owncloud storage driver. We need to switch it
## to the eoshome driver and make it use the storage id of the eos storage provider:
##
docker-compose -f $compose_yml exec ocis $ocis_bin kill storage-storage-home-data
docker-compose -f $compose_yml exec -e STORAGE_STORAGE_HOME_DATA_DRIVER=eoshome ocis $ocis_bin run storage-storage-home-data


## MISSING in https://owncloud.github.io/ocis/eos/ ->  https://github.com/owncloud/ocis/issues/361
#
# FIXME: Workaround for https://github.com/owncloud/ocis/issues/396, 
# - Uploads fail with "mismatched offset"
# - eos cp fails with "No space left on device"
wait_for_eos_fst
# expect to see stat.active=online four times!
while [ "\$(docker-compose -f $compose_yml exec ocis eos fs ls -m | grep stat.active=online | wc -l)" -lt 4 ]; do
  sleep 5
  docker-compose -f $compose_yml exec mgm-master eos space set default on
  sleep 5
  docker-compose -f $compose_yml exec ocis eos fs ls
done
wait_for_eos_health

## FIXME: commmented out, to check if still needed
# # enable trashbin
# docker-compose -f $compose_yml exec mgm-master eos space config default space.policy.recycle=on
# docker-compose -f $compose_yml exec mgm-master eos recycle config --add-bin /eos/dockertest/reva/users
# docker-compose -f $compose_yml exec mgm-master eos recycle config --size 1G

# show some nice stats
docker-compose -f $compose_yml exec ocis eos fs ls --io | sed -e 's/  / /g'
docker-compose -f $compose_yml exec ocis eos space ls --io


if [ -f ~/make_machine.bashrc ]; then
  echo >  $version_file '\`\`\`'
  echo >> $version_file "OCIS_VERSION:         $OCIS_VERSION"
  echo >> $version_file "ocis --version:       \$(docker-compose -f $compose_yml exec ocis $ocis_bin --version)"
  echo >> $version_file "git log:              \$(git log --decorate=full | head -1)"
  echo >> $version_file "eos --version:        \$(docker-compose -f $compose_yml exec ocis eos --version | head -1)"
  echo >> $version_file "xrootd -v:            \$(docker-compose -f $compose_yml exec ocis /opt/eos/xrootd/bin/xrootd -v)"
  # echo >> $version_file "rpm -q quarkdb:       \$(docker-compose -f $compose_yml exec quark-3 rpm -q quarkdb)"
  # echo >> $version_file "rpm -q zeromq:        \$(docker-compose -f $compose_yml exec quark-3 rpm -q zeromq)"
  # echo >> $version_file "rpm -q eos-protobuf3: \$(docker-compose -f $compose_yml exec quark-3 rpm -q eos-protobuf3)"
  echo >> $version_file "$ocis_bin contains:"
  docker-compose -f $compose_yml exec ocis strings $ocis_bin | grep '^dep\s.*owncloud' | sort -u >> $version_file
  ## FIXME: six of these versions are still unintialized. E.g. "ocis-phoenix   v0.0.0-00010101000000-000000000000"


  # make some files appear within the owncloud
  echo '\`\`\`' > ~/make_machine.bashrc.md
  cat ~/make_machine.bashrc >>  ~/make_machine.bashrc.md
  docker cp ~/make_machine.bashrc.md ocis:/
  docker cp $version_file            ocis:/

#   # Fix https://github.com/owncloud/product/issues/127
#   # try auto-create einstein's home
#   curl -k -X PROPFIND https://$IPADDR:9200/remote.php/webdav -u einstein:relativity
#   if ! docker-compose -f $compose_yml exec ocis eos ls -la $eos_home_einstein; then
#     echo ""
#     echo "WARNING: failed to auto-create home of user einstein. Trying manually ..."
#     # CAUTION: keep in sync with https://github.com/cs3org/reva/blob/master/pkg/storage/utils/eosfs/eosfs.go#L818-L952
#     docker-compose -f $compose_yml exec ocis eos -r 0 0                    mkdir -p $eos_home_einstein
#     docker-compose -f $compose_yml exec ocis eos -r 0 0     chown $eos_uid:$eos_gid $eos_home_einstein
#     docker-compose -f $compose_yml exec ocis eos attr set sys.allow.oc.sync="1"     $eos_home_einstein
#     docker-compose -f $compose_yml exec ocis eos attr set sys.forced.atomic="1"     $eos_home_einstein
#     docker-compose -f $compose_yml exec ocis eos attr set sys.mask="700"            $eos_home_einstein
#     docker-compose -f $compose_yml exec ocis eos attr set sys.mtime.propagation="1" $eos_home_einstein
#   fi
# 
#   docker-compose -f $compose_yml exec ocis eos -r $eos_uid $eos_gid mkdir $eos_home_einstein/init
#   docker-compose -f $compose_yml exec ocis eos -r $eos_uid $eos_gid cp /$version_file /make_machine.bashrc.md $eos_home_einstein/init/
# 
#   docker-compose -f $compose_yml exec ocis curl $user_portrait_url -so /tmp/Portrait.jpg
#   docker-compose -f $compose_yml exec ocis curl $user_speech_url   -so /tmp/Speech.ogg
#   docker-compose -f $compose_yml exec ocis eos -r $eos_uid $eos_gid cp /tmp/Speech.ogg /tmp/Portrait.jpg $eos_home_einstein/
fi


echo "Now log in with user einstein at https://${IPADDR}:9200"
echo "... and accept the self signed cert"
docker-compose -f $compose_yml exec ocis eos newfind /eos

uptime
sleep 5
cat <<EOM

## To list the globally trashed files (all users):
# docker-compose exec mgm-master eos -r 0 0 recycle ls -g

---------------------------------------------
# This shell is now connected to root@$IPADDR
# Connect your browser or client to

   https://$IPADDR:9200

---------------------------------------------
EOM
EOF

RUN_SCRIPT
