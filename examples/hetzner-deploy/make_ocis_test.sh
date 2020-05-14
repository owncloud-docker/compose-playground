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

if [ -z "$TF_USER" ]; then
  echo "Env variable TF_USER is not set. Please specify what should be shown as the owner of the machine"
  exit 1;
fi

bash ./make_machine.sh %s-ocis-test-%s -p git,screen,build-essential,docker.io,docker-compose
ipaddr=$(cd terraform; bin/terraform output ipv4)
name=$(cd terraform; bin/terraform output name)

if [ -z "$ipaddr" ]; then
  echo "Error: make_machine.sh failed."
  exit 1;
fi

ssh root@$ipaddr bash -x -s <<EOF
  git clone https://github.com/owncloud/ocis.git # -b v1.0.0-beta4
  git clone https://github.com/owncloud/ocis-phoenix.git		# from mbarz
  wget -q https://dl.google.com/go/go1.14.2.linux-amd64.tar.gz
  mkdir -p /usr/local/bin
  tar xf go1.14.2.linux-amd64.tar.gz -C /usr/local
  ln -s /usr/local/go/bin/* /usr/local/bin

  # disable ipv6, to not confuse ocis server:
  echo >> /etc/sysctl.conf "net.ipv6.conf.all.disable_ipv6 = 1"
  echo >> /etc/sysctl.conf "net.ipv6.conf.default.disable_ipv6 = 1"
  echo >> /etc/sysctl.conf "net.ipv6.conf.lo.disable_ipv6 = 1"
  echo >> /etc/sysctl.conf "net.ipv6.conf.eth0.disable_ipv6 = 1"
  sysctl -p
EOF

cat <<EOF
---------------------------------------------
# machine prepared, now try:
	ssh root@$ipaddr

	cd ocis
	make generate build
	mkdir -p /var/tmp/reva/root/{home,oc}
	./bin/ocis server

# or (via docker-compose)

	git clone https://github.com/owncloud-docker/compose-playground.git
	cd compose-playground/compose/ocis
	sed -i -e 's/your-url/$ipaddr/g' config/identifier-registration.yml
	echo >> .env OCIS_BASE_URL=$ipaddr
	echo >> .env OCIS_HTTP_PORT=9200
	echo >> .env OCIS_DOCKER_TAG=1.0.0-beta4
	docker-compose -f ocis.yml -f ../cache/redis-ocis.yml up

# connect from remote:
	curl -k https://$ipaddr:9200/status.php
        ssh -f -L 9200:localhost:9200 root@$ipaddr sleep 300
	# within 5 min, point your owncloud desktop client to https://localhost:9200


# Follow the instructions at
	https://github.com/owncloud/ocis/#quickstart
	https://owncloud.github.io/ocis/getting-started/#docker-compose
	https://github.com/owncloud/ocis/blob/master/docs/basic-remote-setup.md#use-docker-compose


# When you no longer need the machine, destroy it with e.g.
        bash ./destroy_machine.sh $name

---------------------------------------------
EOF
