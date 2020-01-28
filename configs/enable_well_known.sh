#!/usr/bin/env bash
set -xe

sed -i 's/# Let browsers cache CSS, JS files for half a year/<Files apple-app-site-association>\n    Header set Content-type application\/json\n  <\/Files>/g' /var/www/owncloud/.htaccess
sed -i 's/\/(acme-challenge|pki-validation)//g' /var/www/owncloud/.htaccess

true
