#!/bin/bash
#
# 2021-02-03, jw@owncloud.com
#
# Special apps supported:
# - files_antivirus with a local clamav
# - icap with dockerized clamav-c-icap
# - icap with (if tar and key are present) Kasperksy Scanengine

echo "Estimated setup time: 10 minutes ..."

vers=10.6.0
tar=https://download.owncloud.org/community/owncloud-complete-20201216.tar.bz2

if [ -z "$1" ]; then
  echo "Usage example:"
  echo "  $0 https://github.com/owncloud/files_antivirus/releases/download/v0.16.0RC1/files_antivirus-0.16.0RC1.tar.gz ~/Download/apps/icap-1.0.0RC2.tar.gz Kaspersky_ScanEngine-Linux-x86_64-2.0.0.1157-Release.tar.gz 575F7141.key"
  exit 1
fi

d_vers=$(echo $vers  | tr '[A-Z]' '[a-z]' | tr . -)-$(date +%Y%m%d)
source lib/make_machine.sh -u oc-$d_vers -p git,screen,wget,apache2,ssl-cert "$@"

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

# Accept local files and remote URLs
install_app() { ( test -f "\$1" && cat "\$1" || curl -L -s "\$1" ) | su www-data -s /bin/sh -c 'tar zxvf - -C /var/www/owncloud/apps-external'; }
install_app_gh() { curl -L -s "https://github.com/owncloud/\$1/releases/download/v\$2/\$1-\$2.tar.gz" | su www-data -s /bin/sh -c 'tar zxvf - -C /var/www/owncloud/apps-external'; }

for param in \$PARAM; do
  case "\$param" in
    *.tar.gz)
      app=\$(basename \$param)
      app_name=\$(echo "\$app" | sed -e 's/[-\\.].*//')
      install_app \$app
      case "\$app" in
        files_antivirus*)
          rm -rf /var/www/owncloud/apps/files_antivirus
          occ config:app:set files_antivirus av_socket --value="/var/run/clamav/clamd.ctl"
          occ config:app:set files_antivirus av_mode --value="socket"
          occ app:check files_antivirus         	# https://github.com/owncloud/files_antivirus/issues/394
          occ app:enable files_antivirus

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
        ;;

        icap*)
          apt install -y jq p7zip-full postgresql
	  # first: ClamAV c-icap
          apt install -y jq
	  screen -d -m -S c-icap docker run --rm --name c-icap -ti -p1344:1344 deepdiver/icap-clamav-service
	  for i in 10 9 8 7 6 5 4 3 2 1; do
	    cicap_addr=\$(docker inspect c-icap 2>/dev/null| jq .[0].NetworkSettings.IPAddress -r);
	    test "\$cicap_addr" != null -a "\$cicap_addr" != "" && break;
	    echo "waiting for c-icap: \$i"; sleep 5;
	  done
	  echo -e "\r\n\r" | netcat $cicap_addr 1344 | grep Server
	  occ app:enable files-antivirus
	  occ app:enable icap
	  occ config:system:set files-antivirus.scanner-class    --value='OCA\\ICAP\\Scanner'
	  occ config:system:set files-antivirus.icap.host        --value=$cicap_addr
	  occ config:system:set files-antivirus.icap.req-service --value=avscan         # 'avscan': c-icap clamav; 'req': Kaspersky
	  occ config:system:set files-antivirus.icap.port        --value=1344
	  occ config:system:set files-antivirus.icap.max-transmission --value=4294967296

	  # second: Kaspersky Scanengine
	  echo "listen_addresses = '*'" >> /etc/postgresql/12/main/postgresql.conf        # we don't know the IP yet.
	  grep '^port' /etc/postgresql/12/main/postgresql.conf                            # default 5432
	  su - postgres sh -c "psql -c \"alter user postgres with password 'ps4kas';\""
	  su - postgres sh -c "psql -c \"drop database kavebase;\""	2>/dev/null
	  su - postgres sh -c "psql -c \"drop user icap;\""		2>/dev/null
	  echo >> /etc/postgresql/12/main/pg_hba.conf     "host    all   all      172.17.0.1/16  md5"
	  echo >> /etc/postgresql/12/main/pg_hba.conf     "local   all   postgres                md5"
	  service postgresql restart

	  rm -rf /opt/kaspersky
	  if [ -f Kaspersky_ScanEngine-Linux*.tar.gz ]; then
	    tar xf Kaspersky_ScanEngine-Linux*.tar.gz
	    cd Kasperksy_ScanEngine-Linux*
	    screen -L -S kasinstall ./install
	    for a in "" q Yes Yes Yes No 127.0.0.1:5432 postgres ps4kas icap Ps4_kasp Ps4_kasp 2 11344 No No /tmp 1 /root/ Yes; do
	      screen -S kasinstall -X stuff "\$a\\n"
	      sleep 1
	      cat screenlog.0
	      sleep 1
            done
	    for i in 1 2 3 4; do sleep 3; cat screenlog.0; done
	    ## Per default Kaspersky does not send the virus name in a header,
	    sed -i -e 's@<VirusNameICAPHeader.*@<VirusNameICAPHeader>X-Infection-Found</VirusNameICAPHeader> <SentVirusNameICAPHeader>X-Infection-Found</SentVirusNameICAPHeader>@' /opt/kaspersky/ScanEngine/etc/kavicapd.xml
	    /opt/kaspersky/ScanEngine/etc/init.d/kavicapd restart

	    echo "To switch icap from from clamav-icap to kaspersky run these commands:"
	    echo "  occ config:system:set files-antivirus.icap.host        --value=127.0.0.1"
	    echo "  occ config:system:set files-antivirus.icap.req-service --value=req"
	    echo "  occ config:system:set files-antivirus.icap.port        --value=11344"
	  fi
        ;;

        *)
          echo "\$app installed. Try this to get activate: occ app:enable \$app_name"
        ;;

      esac
      occ app:list files_antivirus
      ;;

    *)
      echo "File uploaded: \$param"

    ;;
  esac
done


uptime
echo "Try: firefox https://$IPADDR/owncloud"
EOF