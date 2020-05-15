#! /bin/sh
# simple factory switcher

libdir=$(dirname $0)/lib
test -z "$OC_DEPLOY" -a -n "$OC_DEPLOY_ADDR" && OC_DEPLOY=simple
test -z "$OC_DEPLOY" -a -n "$TF_VAR_hcloud_token" && OC_DEPLOY=hcloud_tf
test -z "$OC_DEPLOY" -o ! -d $libdir/$OC_DEPLOY && { echo "OC_DEPLOY is undefined, try one of: $(ls -m $libdir)"; exit 1; }
exec $libdir/$OC_DEPLOY/$(basename $0) "$@"

