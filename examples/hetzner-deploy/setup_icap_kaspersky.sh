#! /bin/bash
#
# prepare a test setup for files_antrivirus with icap
#

av_version=0.16.0RC1
av_app=https://github.com/owncloud/files_antivirus/releases/download/v$av_version/files_antivirus-$av_version.tar.gz 
icap_app=~/Downloads/apps/icap-1.0.0RC2.tar.gz		# cannot use a URL, it is in a private repo

if [ -z "$KASKPERSKY_KSE_RELEASE" ]; then
  echo "Env var KASKPERSKY_KSE_RELEASE not set. Please specify a fresh(!) file download url as used when clicking on the share website. (Or a local filename)"
fi
if [ -z "$KASKPERSKY_KSE_LICENSE" ]; then
  echo "Env var KASKPERSKY_KSE_LICENSE not set. Scanning current directory for a Kaspersky *.key file ..."
  for cand in ./*.key; do
    if [ -n "$(strings "$cand" | grep Kaspersky)" ]; then
      KASKPERSKY_KSE_LICENSE=$cand
    fi
  done
  test -n "$KASKPERSKY_KSE_LICENSE" && echo "... found $KASKPERSKY_KSE_LICENSE"
fi
if [ -z "$KASKPERSKY_KSE_LICENSE" -o -z "$KASKPERSKY_KSE_RELEASE" ]; then exit 1; fi

set -x
bash ./make_oc10_apps.sh $av_app $icap_app $KASKPERSKY_KSE_RELEASE $KASKPERSKY_KSE_LICENSE
