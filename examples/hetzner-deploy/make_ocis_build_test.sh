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

  # disable ipv6, to not confuse ocis server:
  echo >> /etc/sysctl.conf "net.ipv6.conf.all.disable_ipv6 = 1"
  echo >> /etc/sysctl.conf "net.ipv6.conf.default.disable_ipv6 = 1"
  echo >> /etc/sysctl.conf "net.ipv6.conf.lo.disable_ipv6 = 1"
  echo >> /etc/sysctl.conf "net.ipv6.conf.eth0.disable_ipv6 = 1"
  sysctl -p

  cd ocis
  make generate build
  mkdir -p /var/tmp/reva/root/{home,oc}
  ./bin/ocis server

  cat <<EOM
---------------------------------------------
### FIXME: developer build may not works using a remote IPADDR
### You may try to workaround using https://localhost:9200
# after adding local port forwarding with
    ssh -f -L 9200:localhost:9200 root@$IPADDR sleep 300

# test connect from remote:
  curl -k https://$IPADDR:9200/status.php

# Follow the instructions at
	https://github.com/owncloud/ocis/#quickstart
	https://owncloud.github.io/ocis/getting-started/#docker-compose
	https://github.com/owncloud/ocis/blob/master/docs/basic-remote-setup.md#use-docker-compose
---------------------------------------------
EOM
EOF

RUN_SCRIPT
