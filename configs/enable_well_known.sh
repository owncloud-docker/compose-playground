#!/usr/bin/env bash
set -xe

sed -i 's/\/(acme-challenge|pki-validation)//g' /var/www/owncloud/.htaccess

true
