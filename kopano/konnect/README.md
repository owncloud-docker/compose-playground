Setup the domain name in /etc/hosts - assuming you are on linux

127.0.0.1 konnect.docker-playground.local
127.0.0.1 owncloud.docker-playground.local

```console
KOPANO_KONNECT_DOMAIN=konnect.docker-playground.local
OWNCLOUD_DOMAIN=owncloud.docker-playground.local
docker-compose \
    -f owncloud-base.yml \
    -f owncloud-official.yml \
    -f cache/redis.yml \
    -f database/mariadb.yml \
    -f ldap/openldap.yml \
    -f ldap/openldap-mount-ldif.yml \
    -f ldap/openldap-autoconfig-base.yml \
    -f kopano/konnect/docker-compose.yml \
    up
```

Go to owncloud: https://owncloud.docker-playground.local
Click the alternative login button 'Kopano'

On the login of kopano konnect use aaliyah_abernathy / secret to login

This is the well-known address to be used for OpenID Connect
https://konnect.docker-playground.local/.well-known/openid-configuration

