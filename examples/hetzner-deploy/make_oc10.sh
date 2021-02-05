#!/bin/bash
#
# 2021-02-03, jw@owncloud.com
#

echo "Estimated setup time: 5 minutes ..."

vers=10.6.0
tar=https://download.owncloud.org/community/owncloud-complete-20201216.tar.bz2
files_antivirus_version=0.16.0RC1	# comment to disable/enable

d_vers=$(echo $vers  | tr '[A-Z]' '[a-z]' | tr . -)-$(date +%Y%m%d)
source lib/make_machine.sh -u oc-$d_vers -p git,screen,wget,apache2,ssl-cert


dbpass="$(tr -dc 'a-z0-9' < /dev/urandom | head -c 10)"

INIT_SCRIPT << EOF
LC_ALL=C
# FROM https://doc.owncloud.com/server/admin_manual/installation/ubuntu_18_04.html
apt install -y apache2 libapache2-mod-php mariadb-server openssl php-imagick php-common php-curl php-gd php-imap php-intl
apt install -y php-json php-mbstring php-mysql php-ssh2 php-xml php-zip php-apcu php-redis redis-server wget
apt install -y ssh bzip2 rsync curl jq inetutils-ping smbclient coreutils php-ldap 	# MISSING: php-smbclient

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

curl -k https://$IPADDR/owncloud/status.php
echo; sleep 5
cd

#################################################################

install_app() { curl -L -s \$1 | su www-data -s /bin/sh -c 'tar zxvf - -C /var/www/owncloud/apps-external'; }

if [ -n "$files_antivirus_version" ]; then
  rm -rf /var/www/owncloud/apps/files_antivirus 
  install_app https://github.com/owncloud/files_antivirus/releases/download/v$files_antivirus_version/files_antivirus-$files_antivirus_version.tar.gz
  occ config:app:set files_antivirus av_socket --value="/var/run/clamav/clamd.ctl"
  occ config:app:set files_antivirus av_mode --value="socket"
  occ app:check files_antivirus         	# https://github.com/owncloud/files_antivirus/issues/394
  occ app:enable files_antivirus
  occ app:list files_antivirus

  apt install -y clamav clamav-daemon
  echo >> /etc/clamav/clamd.conf "TCPSocket 3310"
  sed -i -e 's/LogVerbose false/LogVerbose true/' /etc/clamav/*.conf
  /etc/init.d/clamav-daemon restart
  sleep 20	# waiting for clamd to get ready...
  set -x
  wget https://secure.eicar.org/eicar.com.txt
  clamscan eicar.com.txt
  set +x
  for i in 10 9 8 7 6 5 4 3 2 1; do
    test -e /var/run/clamav/clamd.ctl && break;
    echo " ... waiting for socket ... \$i min"
    sleep 20
    test -e /var/run/clamav/clamd.ctl && break;
    sleep 20
    test -e /var/run/clamav/clamd.ctl && break;
    sleep 20
    /etc/init.d/clamav-daemon restart
  done
  netstat -a | grep clam
fi

uptime
echo "Try: firefox https://$IPADDR/owncloud"
EOF
