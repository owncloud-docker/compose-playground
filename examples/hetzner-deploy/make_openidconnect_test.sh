#!/bin/bash
#
# see also:
#  https://github.com/owncloud-docker/compose-playground/issues/6
#  https://github.com/owncloud-docker/compose-playground/pull/51 	pmaier-fixes 
#  https://github.com/owncloud-docker/compose-playground/blob/master/compose/kopano/konnect/README.md
#
# CAUTION: Do not use obvious README in https://github.com/owncloud/openidconnect/ - it is wrong.
#
# 2020-09-01, jw@owncloud.com
#

echo "Estimated setup time: 8 minutes ..."

source ./make_machine.sh -u openidconnet-test -p git,screen,docker.io,docker-compose

comp_yml=compose-playground/compose/kopano/konnect/docker-compose.yml
openidconnect_url=https://github.com/owncloud/openidconnect/releases/download/v0.2.0/openidconnect-0.2.0.tar.gz
#openidconnect_url=https://github.com/owncloud/openidconnect/releases/download/v1.0.0/openidconnect-1.0.0.tar.gz

LOAD_SCRIPT << EOF
  git clone https://github.com/owncloud-docker/compose-playground.git

  # allow switch back and forth
  sed -i -e 's@OWNCLOUD_APPS_INSTALL=.*@OWNCLOUD_APPS_INSTALL=$openidconnect_url@' $comp_yml
  # already committed to branch pmaier-fixes:
  # sed -i -e 's/OWNCLOUD_APPS_ENABLE=.*/OWNCLOUD_APPS_ENABLE=openidconnect/' $comp_yml
  grep OWNCLOUD_APPS_ $comp_yml

  # disable ipv6, to not confuse ocis server:
  echo >> /etc/sysctl.conf "net.ipv6.conf.all.disable_ipv6 = 1"
  echo >> /etc/sysctl.conf "net.ipv6.conf.default.disable_ipv6 = 1"
  echo >> /etc/sysctl.conf "net.ipv6.conf.lo.disable_ipv6 = 1"
  echo >> /etc/sysctl.conf "net.ipv6.conf.eth0.disable_ipv6 = 1"
  sysctl -p

  # cleanup orphaned volumes!
  docker system prune -f
  docker volume prune -f

  export KOPANO_KONNECT_DOMAIN=konnect.docker-playground.local
  export OWNCLOUD_DOMAIN=owncloud.docker-playground.local
  echo >> /etc/hosts 127.0.0.1 $KOPANO_KONNECT_DOMAIN
  echo >> /etc/hosts 127.0.0.1 $OWNCLOUD_DOMAIN

  cd compose-playground/compose
  git checkout pmaier-fixes || true
  docker-compose \
    -f owncloud-base.yml \
    -f owncloud-official.yml \
    -f cache/redis.yml \
    -f database/mariadb.yml \
    -f ldap/openldap.yml \
    -f ldap/openldap-mount-ldif.yml \
    -f owncloud-exported-ports.yml \
    -f ldap/openldap-autoconfig-base.yml \
    -f kopano/konnect/docker-compose.yml \
    config > openidconnect.yml
  docker-compose -f openidconnect.yml up -d

  cat <<EOM
---------------------------------------------
# start a screen session, watch the logs with
	docker-compose -f openidconnect.yml logs -f

# when everything is done, check the app and sync the users:
	docker exec compose_owncloud_1 occ app:list openidconnect
	docker exec compose_owncloud_1 occ user:sync --missing-account-action=disable 'OCA\User_LDAP\User_Proxy'

# then connect from remote:
	curl -k https://konnect.docker-playground.local/.well-known/openid-configuration
	curl -k http://$IPADDR:9680/status.php
	firefox http://$IPADDR:9680

# you may need to add the remote server to your local hosts file
	echo $IPADDR $KOPANO_KONNECT_DOMAIN  | sudo tee -a /etc/hosts
  	echo $IPADDR $OWNCLOUD_DOMAIN | sudo tee -a /etc/hosts

# Follow the instructions at
	https://github.com/owncloud-docker/compose-playground/blob/pmaier-fixes/compose/kopano/konnect/README.md
---------------------------------------------
EOM
EOF

RUN_SCRIPT
