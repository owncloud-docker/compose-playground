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

if [ -z "$TF_USER" ]; then
  echo "Env variable TF_USER is not set. Please specify what should be shown as the owner of the machine"
  exit 1;
fi
suffix=$(tr -dc 'a-z0-9' < /dev/urandom | head -c 5)

echo "Estimated setup time (when weather is fine): 10 minutes ..."
sleep 2; echo ""; sleep 2; echo ""; sleep 2

name=$TF_USER-ocis-eos-test-$suffix
bash ./make_machine.sh $name -p git,screen,build-essential,docker.io
ipaddr=$(cd terraform; bin/terraform output ipv4)

if [ -z "$ipaddr" ]; then
  echo "Error: make_machine.sh failed."
  exit 1;
fi

ssh root@$ipaddr bash -x -s << EOF
  git clone https://github.com/owncloud/ocis.git # -b v1.0.0-beta4
  wget -q https://dl.google.com/go/go1.14.2.linux-amd64.tar.gz
  mkdir -p /usr/local/bin
  tar xf go1.14.2.linux-amd64.tar.gz -C /usr/local
  ln -s /usr/local/go/bin/* /usr/local/bin
EOF

cat <<EOF | ssh root@$ipaddr dd of=/tmp/blurb.txt
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
        bash ./destroy_machine.sh $name

---------------------------------------------
EOF

ssh -t root@$ipaddr sh -c "echo dummy; cd ocis; make eos-start; (sleep 15; cat /tmp/blurb.txt)& exec bash"

sleep 2; echo ""; sleep 2; echo ""; sleep 2
cat <<EOF2
---------------------------------------------
# When you no longer need the machine, destroy it with e.g.
        bash ./destroy_machine.sh $name

---------------------------------------------
EOF2
