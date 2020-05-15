#!/bin/bash
#
# see also:
#  https://golang.org/doc/install
#  https://github.com/owncloud/ocis/
#  https://owncloud.github.io/
#
# This sets up an ocis dev environment in 2min 30sec.
# Building ocis again takes ca 3min.
#
# 2020-04-15, jw@owncloud.com
#

source ./make_machine.sh -u ocis-test -p git,screen,build-essential,docker.io,docker-compose

LOAD_SCRIPT << EOF
  # make from source
  git clone https://github.com/owncloud/ocis.git # -b v1.0.0-beta4
  git clone https://github.com/owncloud/ocis-phoenix.git		# from mbarz
  wget -q https://dl.google.com/go/go1.14.2.linux-amd64.tar.gz
  mkdir -p /usr/local/bin
  tar xf go1.14.2.linux-amd64.tar.gz -C /usr/local
  ln -s /usr/local/go/bin/* /usr/local/bin

  # compose docker container
  git clone https://github.com/owncloud-docker/compose-playground.git
  sed -i -e 's/your-url/$IPADDR/g' compose-playground/compose/ocis/config/identifier-registration.yml

  # disable ipv6, to not confuse ocis server:
  echo >> /etc/sysctl.conf "net.ipv6.conf.all.disable_ipv6 = 1"
  echo >> /etc/sysctl.conf "net.ipv6.conf.default.disable_ipv6 = 1"
  echo >> /etc/sysctl.conf "net.ipv6.conf.lo.disable_ipv6 = 1"
  echo >> /etc/sysctl.conf "net.ipv6.conf.eth0.disable_ipv6 = 1"
  sysctl -p

  cat <<EOM
---------------------------------------------
# machine prepared, now try:
	ssh root@$IPADDR
	cd ocis
	make generate build
	mkdir -p /var/tmp/reva/root/{home,oc}
	./bin/ocis server

# or (via docker-compose)
	ssh root@$IPADDR
	cd compose-playground/compose/ocis
	echo >> .env OCIS_BASE_URL=$IPADDR
	echo >> .env OCIS_HTTP_PORT=9200
	echo >> .env OCIS_DOCKER_TAG=1.0.0-beta4
	docker-compose -f ocis.yml -f ../cache/redis-ocis.yml up

# connect from remote:
	curl -k https://$IPADDR:9200/status.php
        ssh -f -L 9200:localhost:9200 root@$IPADDR sleep 300
	# within 5 min, point your owncloud desktop client to https://localhost:9200

# Follow the instructions at
	https://github.com/owncloud/ocis/#quickstart
	https://owncloud.github.io/ocis/getting-started/#docker-compose
	https://github.com/owncloud/ocis/blob/master/docs/basic-remote-setup.md#use-docker-compose
---------------------------------------------
EOM
EOF

RUN_SCRIPT
