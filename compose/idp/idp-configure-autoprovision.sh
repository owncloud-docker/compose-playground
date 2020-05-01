#!/usr/bin/env bash
set -x

echo "Configuring user_shibboleth"

occ app:enable user_shibboleth
occ shibboleth:mode autoprovision
occ shibboleth:mapping --uid=uid --email=email --display-name=displayName --shib-session=Shib-Session-ID

