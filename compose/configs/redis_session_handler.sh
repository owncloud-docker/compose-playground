#!/usr/bin/env bash
set -x

OC_INI_PATH="/etc/php/7.0/mods-available/owncloud.ini"

echo "session.save_handler = redis" >> $OC_INI_PATH
echo "session.save_path = \"tcp://redis:6379\"" >> $OC_INI_PATH
cat $OC_INI_PATH