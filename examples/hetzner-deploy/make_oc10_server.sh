#!/bin/bash
#
# 2021-01-26, jw@owncloud.com
#

echo "Estimated setup time: 2 minutes ..."

vers=10.6.0
d_vers=$(echo $vers  | tr '[A-Z]' '[a-z]' | tr . -)-$(date +%Y%m%d)
source lib/make_machine.sh -u oc-$d_vers -p git,screen,docker.io,wget

HTTP_PORT=80

INIT_SCRIPT << EOF
  mkdir -p /tmp/ocmount
  docker run -d --rm -v /tmp/ocmount:/mnt/data -p $HTTP_PORT:8080 owncloud/server:$vers &
  
  echo "Try: docker logs -f \$(docker ps -q)"
  echo "Try: docker exec \$(docker ps -q) bash"
  echo "Try: firefox http://$IPADDR:80"
EOF
