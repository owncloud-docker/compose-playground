#!/usr/bin/env bash
set -x

echo "Configuring user_shibboleth"

occ app:enable user_shibboleth
occ shibboleth:mode ssoonly
occ shibboleth:mapping --uid=uid --shib-session=Shib-Session-ID

