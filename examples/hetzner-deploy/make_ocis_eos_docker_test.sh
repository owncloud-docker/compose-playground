#!/bin/bash
#
# see also:
#  https://github.com/AARNet/eos-docker/blob/master/README.md
#  https://github.com/owncloud-docker/compose-playground/tree/master/examples/play-ocis
#  https://github.com/owncloud-docker/compose-playground/tree/eos/examples/eos-docker#eos-docker
#  https://owncloud.github.io/
#
# 2020-05-14, jw@owncloud.com

echo "Estimated setup time (when weather is fine): 6 minutes ..."
sleep 2; echo ""; sleep 2; echo ""; sleep 2

bash ./make_machine.sh %s-ocis-eos-docker-test-%s -p git,screen,docker.io,docker-compose
ipaddr=$(cd terraform; bin/terraform output ipv4)
name=$(cd terraform; bin/terraform output name)

if [ -z "$ipaddr" ]; then
  echo "Error: make_machine.sh failed."
  exit 1;
fi

ssh root@$ipaddr tee init.bashrc > /dev/null <<EOF
  svcfile=/usr/lib/systemd/system/docker.service			# ubuntu-20.04
  test -e \$svcfile || svcfile=/lib/systemd/system/docker.service	# ubuntu-18.04
  sed -i -e 's@\(\[Service\]\)@\1\nMountFlags=shared@' \$svcfile
  grep -C2 MountFlags \$svcfile
  systemctl daemon-reload
  service docker restart

  git clone https://github.com/owncloud-docker/compose-playground.git -b eos
  cd compose-playground/examples/eos-docker

  # FIXME: shouldn't eos-docker.env be able to do this?
  sed -i -e "s/@IPADDR@/$ipaddr/g" docker-compose.yml

  ./build -t test
  ./setup -a
  docker-compose up ocis &

  sleep 5
  cat <<EOM
---------------------------------------------
# Machine prepared.
#
# This shell is now connected to root@$ipaddr

# follow the instructions at

   https://github.com/owncloud-docker/compose-playground/tree/eos/examples/eos-docker#eos-docker

# Enter 'exit' when done.
# Finally, you should destroy the machine e.g. with
        ./destroy_machine.sh $name

---------------------------------------------
EOM
  . ~/.bashrc
EOF

ssh -t root@$ipaddr bash --rcfile init.bashrc

sleep 2; echo ""; sleep 2
cat <<EOF
---------------------------------------------
# When you no longer need the machine, destroy it with e.g.
        ./destroy_machine.sh $name

---------------------------------------------
EOF
