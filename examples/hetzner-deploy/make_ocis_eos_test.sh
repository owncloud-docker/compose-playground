#!/bin/bash
#
# see also:
#  https://golang.org/doc/install
#  https://owncloud.github.io/
#  https://github.com/owncloud/ocis/blob/master/docs/eos.md#run-it
#
# This sets up an ocis dev environment in 2min 30sec.
# Building ocis again takes ca 3min.
#
# 2020-05-07, jw@owncloud.com

source ./make_machine.sh -u ocis-eos-test -p git,screen,build-essential,docker.io

LOAD_SCRIPT <<EOF
  git clone https://github.com/owncloud/ocis.git # -b v1.0.0-beta4
  wget -q https://dl.google.com/go/go1.14.2.linux-amd64.tar.gz
  mkdir -p /usr/local/bin
  tar xf go1.14.2.linux-amd64.tar.gz -C /usr/local
  ln -s /usr/local/go/bin/* /usr/local/bin

  cd ocis
  make eos-start

  sleep 10
  cat <<EOM
---------------------------------------------
# Machine prepared.
#
# This shell is now connected to root@$ipaddr
# Remote connetions may fail currently.
# To use this instance via localhost port 9200
# Run the following command locally in a different shell:

        ssh -f -L 9200:localhost:9200 root@$ipaddr sleep 300

# Then (within 5 min) you can direct your web browser and/or owncloud client to

        https://localhost:9200
	curl -k https://localhost:9200/status.php

# Follow the instructions at
	https://owncloud.github.io/ocis/eos/#test-it

#
# Enter 'exit' when done.
# Finally, you should destroy the machine e.g. with
        bash ./destroy_machine.sh $NAME

---------------------------------------------
EOM
EOF

RUN_SCRIPT
