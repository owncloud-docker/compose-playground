#!/bin/bash
#
# see also:
#  https://github.com/owncloud-docker/compose-playground/issues/6
#  https://github.com/owncloud-docker/compose-playground/pull/51 	pmaier-fixes 
#  https://github.com/owncloud-docker/compose-playground/blob/master/compose/kopano/konnect/README.md
#  https://doc.owncloud.com/server/10.5/admin_manual/configuration/user/oidc/
#
# CAUTION: Do not use obvious README in https://github.com/owncloud/openidconnect/ - it is wrong.
#
# 2020-09-01, jw@owncloud.com
#

echo "Estimated setup time: 8 minutes ..."

vers=1.0.0RC4
d_vers=$(echo $vers  | tr '[A-Z]' '[a-z]' | tr . -)
source ./make_machine.sh -u openidconnect-$d_vers-test -p git,screen,docker.io,docker-compose

comp_yml=kopano/konnect/docker-compose.yml
#openidconnect_url=https://github.com/owncloud/openidconnect/releases/download/v0.2.0/openidconnect-0.2.0.tar.gz
openidconnect_url=https://github.com/owncloud/openidconnect/releases/download/v$vers/openidconnect-$vers.tar.gz

KOPANO_KONNECT_DOMAIN=konnect.oidc-jw-qa.owncloud.works
OWNCLOUD_DOMAIN=owncloud.oidc-jw-qa.owncloud.works
## if you cannot work with cloudflare, you may try an /etc/hosts setup using:
# KOPANO_KONNECT_DOMAIN=konnect.docker-playground.local
# OWNCLOUD_DOMAIN=owncloud.docker-playground.local

LOAD_SCRIPT << EOF
  git clone https://github.com/owncloud-docker/compose-playground.git
  cd compose-playground/compose
  git checkout pmaier-fixes || true
  git branch -a

  # allow switch back and forth
  sed -i -e 's@OWNCLOUD_APPS_INSTALL=.*@OWNCLOUD_APPS_INSTALL=$openidconnect_url@g' $comp_yml
  # already committed to branch pmaier-fixes:
  # sed -i -e 's/OWNCLOUD_APPS_ENABLE=.*/OWNCLOUD_APPS_ENABLE=openidconnect/g' $comp_yml
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

  export KOPANO_KONNECT_DOMAIN=$KOPANO_KONNECT_DOMAIN
  export OWNCLOUD_DOMAIN=$OWNCLOUD_DOMAIN
  echo >> /etc/hosts 127.0.0.1 $KOPANO_KONNECT_DOMAIN
  echo >> /etc/hosts 127.0.0.1 $OWNCLOUD_DOMAIN

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
    config > oidc-merged.yml
  docker-compose -f oidc-merged.yml up -d

  cat <<EOM
---------------------------------------------
### CAUTION: manual steps required here!

# start a screen session, watch the logs with
	docker-compose -f oidc-merged.yml logs -f

# when everything is done, check the app and sync the users:
	docker exec compose_owncloud_1 occ app:list openidconnect
	docker exec compose_owncloud_1 occ user:sync --missing-account-action=disable 'OCA\User_LDAP\User_Proxy'

# you may now first need to add the DNS entries at dash.cloudflare.com
	$IPADDR $KOPANO_KONNECT_DOMAIN
	$IPADDR $OWNCLOUD_DOMAIN

# and wait for a log message like
	caddy_1           | 2020/09/16 22:36:29 [INFO] [owncloud.oidc-jw-qa.owncloud.works] Server responded with a certificate.

# then connect from remote (certs must be good!):
	curl https://$KOPANO_KONNECT_DOMAIN/.well-known/openid-configuration
	curl http://$IPADDR:9680/status.php
	firefox https://$OWNCLOUD_DOMAIN
	# CAUTION: only use the DNS name. IP Adresses are not supported by our certificates.

# login via 'Kopano' with user: aaliyah_abernathy pass: secret

# you may first need to add the DNS entries to cloudflare or to your local hosts file
	echo $IPADDR $KOPANO_KONNECT_DOMAIN  | sudo tee -a /etc/hosts
  	echo $IPADDR $OWNCLOUD_DOMAIN | sudo tee -a /etc/hosts

# Study
	https://github.com/owncloud-docker/compose-playground/blob/pmaier-fixes/compose/kopano/konnect/README.md
	https://doc.owncloud.com/server/10.5/admin_manual/configuration/user/oidc/

### CAUTION: manual steps required here!
---------------------------------------------
EOM
EOF

RUN_SCRIPT
