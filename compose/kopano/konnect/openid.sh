#!/usr/bin/env bash
set -x

CONFIG=$(cat <<EOF
{
    "system": {
        "openid-connect": {
       		"provider-url": "https://$KOPANO_KONNECT_DOMAIN",
            "client-id": "ownCloud",
            "client-secret": "ownCloud",
            "loginButtonName": "Kopano",
            "autoRedirectOnLoginPage": false,
            "redirect-url": "https://$OWNCLOUD_DOMAIN/index.php/apps/openidconnect/redirect",
            "mode": "userid",
            "search-attribute": "preferred_username"
        },
        "debug": true
    }
}
EOF
)

occ config:import <<< $CONFIG
occ app:enable user_ldap
occ ldap:test-config "s01"

true
