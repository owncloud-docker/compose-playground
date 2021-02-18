#!/bin/bash
#
# 2021-02-03, jw@owncloud.com
#

echo "Estimated setup time: 5 minutes ..."

vers=10.6.0
tar=https://download.owncloud.org/community/owncloud-complete-20201216.tar.bz2

d_vers=$(echo $vers  | tr '[A-Z]' '[a-z]' | tr . -)-$(date +%Y%m%d)
source lib/make_machine.sh -u oc-$d_vers -p git,screen,wget,apache2,ssl-cert,docker.io,jq "$@"

dbpass="$(tr -dc 'a-z0-9' < /dev/urandom | head -c 10)"

INIT_SCRIPT << EOF
export LC_ALL=C LANGUAGE=C
# FROM https://doc.owncloud.com/server/admin_manual/installation/ubuntu_18_04.html
apt install -y apache2 libapache2-mod-php mariadb-server openssl php-imagick php-common php-curl php-gd php-imap php-intl
apt install -y php-json php-mbstring php-mysql php-ssh2 php-xml php-zip php-apcu php-redis redis-server wget
apt install -y ssh bzip2 rsync curl jq inetutils-ping smbclient coreutils php-ldap

cd /var/www
curl $tar | tar jxf -
chown -R www-data. owncloud

cat <<EOCONF > /etc/apache2/sites-available/owncloud.conf
Alias /owncloud "/var/www/owncloud/"

<Directory /var/www/owncloud/>
  Options +FollowSymlinks
  AllowOverride All

 <IfModule mod_dav.c>
  Dav off
 </IfModule>
 SetEnv HOME /var/www/owncloud
 SetEnv HTTP_HOME /var/www/owncloud
</Directory>
EOCONF
for mod in ssl headers env dir mime unique_id; do
  a2enmod \$mod
done
for site in owncloud default-ssl; do
   a2ensite \$site
done
service apache2 restart

cat << EOOCC > /usr/bin/occ
#! /bin/sh
cd /var/www/owncloud
sudo -u www-data /usr/bin/php /var/www/owncloud/occ "\\\$@"
EOOCC
chmod a+x /usr/bin/occ

mysql -u root -e "DROP DATABASE owncloud;" || true
mysql -u root -e "CREATE DATABASE IF NOT EXISTS owncloud; GRANT ALL PRIVILEGES ON owncloud.* TO owncloud@localhost IDENTIFIED BY '$dbpass'";
occ maintenance:install --database "mysql" --database-name "owncloud" --database-user "owncloud" --database-pass "$dbpass" --admin-user "admin" --admin-pass "admin"

occ config:system:set trusted_domains 1 --value="$IPADDR"

echo "*/15  *  *  *  * /var/www/owncloud/occ system:cron" > /var/spool/cron/crontabs/www-data
chown www-data.crontab /var/spool/cron/crontabs/www-data

occ config:system:set memcache.local --value '\OC\Memcache\APCu'
occ config:system:set memcache.locking --value '\OC\Memcache\Redis'
occ config:system:set redis --type json --value '{"host": "127.0.0.1", "port": "6379"}'

## initialize mailhog
docker run --rm --name mailhog -d -p 8025:8025 mailhog/mailhog
hog_ip=$(docker inspect mailhog | jq .[0].NetworkSettings.IPAddress -r)
mysql owncloud -e 'UPDATE oc_accounts SET email="admin@oc.example.com" WHERE user_id="admin";'
occ config:system:set mail_domain       --value oc.example.com
occ config:system:set mail_from_address --value mail
occ config:system:set mail_smtpmode     --value smtp
occ config:system:set mail_smtphost     --value $hog_ip
occ config:system:set mail_smtpport     --value 1025

## external SFTP storage
apt install -y pure-ftpd
ftppass=ftp${RANDOM}data
echo -e "$ftppass\n$ftppass" | adduser ftpdata --gecos ""
occ files_external:create /SFTP sftp password::password -c host=localhost -c root="/home/ftpdata" -c user=ftpdata -c password=$ftppass


curl -k https://$IPADDR/owncloud/status.php
echo; sleep 5
cd

#################################################################
# install_app accepts local files and remote URLs
install_app() { ( test -f "\$1" && cat "\$1" || curl -L -s "\$1" ) | su www-data -s /bin/sh -c 'tar zxvf - -C /var/www/owncloud/apps-external'; }
install_app_gh() { install_app "https://github.com/owncloud/\$1/releases/download/v\$2/\$1-\$2.tar.gz"; }

uptime
cat << EOM
( Mailhog access: http://$IPADDR:8025 )
Server $vers is ready. You can now try the following commands:
From within this machine
	install_app ./icap-0.1.0RC2.tar.gz
	install_app_gh files_antivirus 0.16.0RC1

From remote
	firefox https://$IPADDR/owncloud
EOM
EOF
