#!/bin/bash
#
# 2021-02-03, jw@owncloud.com
#
# Special apps supported:
# - files_antivirus with a local clamav
# - icap with dockerized clamav-c-icap
# - icap with (if tar and key are present) Kaspersky Scan Engine

echo "Estimated setup time: 5 minutes ..."

vers=10.6.0
tar=https://download.owncloud.org/community/owncloud-complete-20201216.tar.bz2

if [ -z "$1" ]; then
  echo "Usage example:"
  echo "  $0 https://github.com/owncloud/files_antivirus/releases/download/v0.16.0RC1/files_antivirus-0.16.0RC1.tar.gz ~/Download/apps/icap-1.0.0RC2.tar.gz Kaspersky_ScanEngine-Linux-x86_64-2.0.0.1157-Release.tar.gz 575F7141.key"
  exit 1
fi

d_vers=$(echo $vers  | tr '[A-Z]' '[a-z]' | tr . -)-$(date +%Y%m%d)
source $(dirname $0)/lib/make_machine.sh -u oc-$d_vers -p git,screen,wget,apache2,ssl-cert,docker.io,jq "$@"

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

<IfModule mod_headers.c>
  Header always set Strict-Transport-Security "max-age=15552000; includeSubDomains"
</IfModule>

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

mysql -u root -e "DROP DATABASE owncloud;" 2>/dev/null || true
mysql -u root -e "CREATE DATABASE IF NOT EXISTS owncloud; GRANT ALL PRIVILEGES ON owncloud.* TO owncloud@localhost IDENTIFIED BY '$dbpass'";
occ maintenance:install --database "mysql" --database-name "owncloud" --database-user "owncloud" --database-pass "$dbpass" --admin-user "admin" --admin-pass "admin"

occ config:system:set trusted_domains 1 --value="$IPADDR"

echo "*/15  *  *  *  * /var/www/owncloud/occ system:cron" > /var/spool/cron/crontabs/www-data
chown www-data.crontab /var/spool/cron/crontabs/www-data
occ background:cron

occ config:system:set memcache.local --value '\OC\Memcache\APCu'
occ config:system:set memcache.locking --value '\OC\Memcache\Redis'
occ config:system:set redis --type json --value '{"host": "127.0.0.1", "port": "6379"}'

## initialize mailhog
docker run --rm --name mailhog -d -p 8025:8025 mailhog/mailhog
hog_ip=\$(docker inspect mailhog | jq .[0].NetworkSettings.IPAddress -r)
mysql owncloud -e 'UPDATE oc_accounts SET email="admin@oc.example.com" WHERE user_id="admin";'
occ config:system:set mail_domain       --value oc.example.com
occ config:system:set mail_from_address --value mail
occ config:system:set mail_smtpmode     --value smtp
occ config:system:set mail_smtphost     --value \$hog_ip
occ config:system:set mail_smtpport     --value 1025

## external SFTP storage
apt install -y pure-ftpd
ftppass=ftp${RANDOM}data
echo -e "\$ftppass\\n\$ftppass" | adduser ftpdata --gecos ""
occ files_external:create /SFTP sftp password::password -c host=localhost -c root="/home/ftpdata" -c user=ftpdata -c password=\$ftppass
occ config:app:set core enable_external_storage --value yes


curl -k https://$IPADDR/owncloud/status.php
echo; sleep 5
cd

#################################################################

# install_app accepts local files and remote URLs
install_app() { ( test -f "\$1" && cat "\$1" || curl -L -s "\$1" ) | su www-data -s /bin/sh -c 'tar zxvf - -C /var/www/owncloud/apps-external'; }
install_app_gh() { install_app "https://github.com/owncloud/\$1/releases/download/v\$2/\$1-\$2.tar.gz"; }

apps_installed=
for param in \$PARAM; do
  # find app tar.gz files by looking for an appinfo/info.xml in them.
  param="\$(basename \$param)"
  if echo "\$param" | grep -q ".tar.gz" && tar tf "\$param" 2>/dev/null | grep -q appinfo/info.xml; then
    app="\$(basename "\$param")"
    app_name=\$(echo "\$app" | sed -e 's/[-\\.].*//')
    install_app "\$app"
    apps_installed="\$apps_installed \$app_name"
    case "\$app" in
      metrics*)
	occ app:enable \$app_name	# CAUTION: triggers license grace period!
	occ config:system:set "metrics_shared_secret" --value 123456
	;;

      windows_network_drive*)
	# See also https://packages.ubuntu.com/search?keywords=php-smbclient
	# A php-smbclient package exists only for ubuntu-18.04, we compile it from source.
	apt install -y php-pear php7.4-dev libsmbclient libsmbclient-dev make smbclient; pecl install smbclient-stable
	echo 'extension="smbclient.so"' > /etc/php/7.4/mods-available/smbclient.ini
	phpenmod -v ALL smbclient
	service apache2 reload
	#
	mkdir -p /home/samba; chmod -R 777 /home/samba
	docker run --rm -v /home/samba:/shared -d --name samba dperson/samba -u "testy;testy" -s "shared;/shared;yes;no;yes" -n
	smb_ip=\$(docker inspect samba | jq .[0].NetworkSettings.IPAddress -r)
        wget https://secure.eicar.org/eicar.com
	smbclient //\$smb_ip/shared -U testy testy -c 'put eicar.com; dir'
        occ app:enable \$app_name	# CAUTION: triggers license grace period!
	occ config:app:set core enable_external_storage --value yes
	occ files_external:create /WND windows_network_drive password::password -c host=\$smb_ip -c share="/shared" -c user=testy -c password=testy
	sleep 2
	screen -d -m -S wnd_listen occ wnd:listen -vvv \$smb_ip shared testy testy 	# from https://github.com/owncloud/windows_network_drive/pull/148/files
	;;

      files_antivirus*)
        rm -rf /var/www/owncloud/apps/files_antivirus
        occ config:app:set files_antivirus av_socket --value="/var/run/clamav/clamd.ctl"
        occ config:app:set files_antivirus av_mode --value="socket"
        occ app:check \$app_name         	# https://github.com/owncloud/files_antivirus/issues/394
        occ app:enable \$app_name

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
        apt install -y jq p7zip-full postgresql docker.io
        # first: ClamAV c-icap
        apt install -y jq
        screen -d -m -S c-icap docker run --rm --name c-icap -ti deepdiver/icap-clamav-service
        for i in 10 9 8 7 6 5 4 3 2 1; do
          cicap_addr=\$(docker inspect c-icap 2>/dev/null| jq .[0].NetworkSettings.IPAddress -r);
          test "\$cicap_addr" != null -a "\$cicap_addr" != "" && break;
          echo "waiting for c-icap: \$i"; sleep 5;
        done
        echo -e "\r\n\r" | netcat "\$cicap_addr" 1344 | grep Server
        occ app:enable files_antivirus
        occ app:enable \$app_name
        occ config:system:set files-antivirus.scanner-class    --value='OCA\\ICAP\\Scanner'
        occ config:system:set files-antivirus.icap.host        --value="\$cicap_addr"
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
        tarname="\$(ls Kaspersky_ScanEngine*.tar.gz | head -n 1)"
        if [ ! -f "\$tarname" ]; then
          echo "Kaspersky_ScanEngine not initialized: No match for Kaspersky_ScanEngine*.tar.gz"
        else
          tar xf "\$tarname"
          tartop="\$(tar tf "\$tarname" | head -n 1 | sed -e 's@^/@@' -e 's@^./@@' -e 's@/.*@@')"
          ( cd "\$tartop"; screen -d -m -L -S kasinstall ./install )
          for a in "" q Yes Yes Yes No 127.0.0.1:5432 postgres ps4kas icap Ps4_kasp Ps4_kasp 2 11344 No No /tmp 1 /root/ Yes; do
            screen -S kasinstall -X stuff "\$a\\n" || echo "failed to stuff \$a"
            sleep 1
            cat screenlog.0
            sleep 1
          done
          for i in 1 2 3 4; do sleep 3; cat screenlog.0; done
          ## Per default Kaspersky does not send the virus name in a header,
          sed -i -e 's@<VirusNameICAPHeader.*@<VirusNameICAPHeader>X-Infection-Found</VirusNameICAPHeader> <SentVirusNameICAPHeader>X-Infection-Found</SentVirusNameICAPHeader>@' /opt/kaspersky/ScanEngine/etc/kavicapd.xml
          /opt/kaspersky/ScanEngine/etc/init.d/kavicapd restart

          echo ""
          echo "Make the Kaspersky ScanEngine Web GUI locally as https://localhost:11443 via ssh-tunnel:"
          echo "  ssh -v -L 11443:127.0.0.1:1443 root@$IPADDR"
	  echo ""
          echo "To review icap settings, use:"
          echo "  occ config:list --output=plain | grep files-antivirus.icap"
          echo "To switch icap from from clamav-icap to kaspersky run these commands:"
          echo "  occ config:system:set files-antivirus.icap.host        --value=127.0.0.1"
          echo "  occ config:system:set files-antivirus.icap.req-service --value=req"
          echo "  occ config:system:set files-antivirus.icap.port        --value=11344"
	  echo ""
          echo "To switch off icap: (Must do this before disabling or uninstalling icap)"
          echo "  occ config:system:delete files-antivirus.scanner-class"
	  echo ""
        fi
      ;;

      *)
        echo "\$app installed. Try this to get activate: occ app:enable \$app_name"
      ;;

    esac
    occ app:list \$app_name

  else
    if [ -e "/root/\$param" ]; then
      echo "File added: /root/\$param"
    else
      echo "env var PARAM contains basename '\$param', but no such file added."
    fi
  fi
done

for app in \$apps_installed; do
  echo -n "Checking app \$app ... "
  occ integrity:check-app \$app && echo "OK." || echo -e "  OOPS. If needed, use:\n\t occ c:s:s integrity.check.disabled --type bool --value true"
done

grace_period="\$(occ config:app:get core grace_period)"
if [ -n "\$grace_period" ]; then
  cat <<GRACE
  Enterprise grace_period activated. Please add a license.key or try:
	sed -i -e 's@60 \\* 24;@60 * 24 * 30;@' /var/www/owncloud/lib/private/License/LicenseManager.php
	occ c:s:set integrity.check.disabled --type bool --value true
	occ c:s:set grace_period.demo_key.show_popup --type bool --value false
GRACE
fi

uptime
cat << EOM
( Mailhog access: http://$IPADDR:8025 )
Server $vers is ready. You can now try e.g. commands like these:
From within this machine
	install_app ./icap-0.1.0RC2.tar.gz
	install_app_gh files_antivirus 0.16.0RC1

From remote
	firefox https://$IPADDR/owncloud
EOM
EOF
