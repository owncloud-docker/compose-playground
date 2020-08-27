#!/usr/bin/env bash
set -x


if [ ! -e "/.shib_installed" ]; then

    echo "Installing dependencies ...."
    apt-get update && apt-get install libapache2-mod-shib2 -y -o Dpkg::Options::="--force-confold";
    shib-keygen
    sed -i 's|</Attributes>|\t<Attribute name="urn:oid:0.9.2342.19200300.100.1.1" id="uid"/>\n</Attributes>|' /etc/shibboleth/attribute-map.xml
    sed -i 's|</Attributes>|\t<Attribute name="urn:oid:2.16.840.1.113730.3.1.241" id="displayName"/>\n</Attributes>|' /etc/shibboleth/attribute-map.xml
    sed -i 's|</Attributes>|\t<Attribute name="urn:oid:1.2.840.113549.1.9.1" id="email"/>\n</Attributes>|' /etc/shibboleth/attribute-map.xml
    a2enmod shib2
    touch /.shib_installed
fi

