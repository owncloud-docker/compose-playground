#!/usr/bin/env bash
set -x


if [ ! -e "/.shib_installed" ]; then

    echo "Installing dependencies ...."
    apt update && apt install nano libapache2-mod-shib2 -y -o Dpkg::Options::="--force-confold";
    shib-keygen
    sed -i 's|</Attributes>|\t<Attribute name="urn:oid:0.9.2342.19200300.100.1.1" id="uid"/>\n</Attributes>|' /etc/shibboleth/attribute-map.xml
    a2enmod shib2

    ENTITY_ID=$(date +%s | sha256sum | base64 | head -c 32)

SHIBCONFIG=$(cat <<EOF
<SPConfig xmlns="urn:mace:shibboleth:2.0:native:sp:config" xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata" clockSkew="1800">
    <ApplicationDefaults entityID="${ENTITY_ID}" REMOTE_USER="eppn">
        <Sessions lifetime="28800" timeout="3600" checkAddress="false" relayState="ss:mem" handlerSSL="false">
            <SSO entityID="https://idp.testshib.org/idp/shibboleth">
                SAML2 SAML1
            </SSO>
            <Logout>SAML2 Local</Logout>
            <Handler type="MetadataGenerator" Location="/Metadata" signing="false"/>
            <Handler type="Status" Location="/Status" acl="127.0.0.1"/>
            <Handler type="Session" Location="/Session" showAttributeValues="true"/>
            <Handler type="DiscoveryFeed" Location="/DiscoFeed"/>
        </Sessions>
        <Errors supportContact="root@localhost" logoLocation="/shibboleth-sp/logo.jpg" styleSheet="/shibboleth-sp/main.css"/>
        <MetadataProvider type="XML" uri="http://www.testshib.org/metadata/testshib-providers.xml" backingFilePath="testshib-two-idp-metadata.xml" reloadInterval="180000" />
        <AttributeExtractor type="XML" validate="true" path="attribute-map.xml"/>
        <AttributeResolver type="Query" subjectMatch="true"/>
        <AttributeFilter type="XML" validate="true" path="attribute-policy.xml"/>
        <CredentialResolver type="File" key="sp-key.pem" certificate="sp-cert.pem"/>
    </ApplicationDefaults>
    <SecurityPolicyProvider type="XML" validate="true" path="security-policy.xml"/>
    <ProtocolProvider type="XML" validate="true" reloadChanges="false" path="protocols.xml"/>
</SPConfig>
EOF
)
    echo "${SHIBCONFIG}" > /etc/shibboleth/shibboleth2.xml

    # finished - do not rerun this step
    touch /.shib_installed
fi
