# oC10 with ocis-infra

![alt text](https://mermaid.ink/svg/eyJjb2RlIjoiZ3JhcGggVERcbiBvY2lzLXByb3h5IC0tPiBvYzEwXG4gb2Npcy1wcm94eSAtLT4gb2Npcy1pZHBcbiBvY2lzLWlkcCAtLT4gfExEQVB8b2Npcy1nbGF1dGhcbiBvYzEwIC0tPiB8TERBUHxvY2lzLWdsYXV0aFxuXHRcdCIsIm1lcm1haWQiOnsidGhlbWUiOiJkZWZhdWx0In0sInVwZGF0ZUVkaXRvciI6ZmFsc2V9)

ownCloud 10 with OIDC behind ocis-reverse-proxy and ocis-glauth as user-backend.
 
## Run
Add ```127.0.0.1 ocis``` to /etc/host
```bash
docker-compose up
```
## Add local users
```bash
docker-compose exec -e OC_PASS=relativity owncloud occ user:add einstein --password-from-env
docker-compose exec -e OC_PASS=radioactivity owncloud occ user:add marie --password-from-env
```
## OIDC-Login
- Visit https://ocis:9200 and click the OpenId Connect Button. 
- You will be redirected to the idp.
- Use the credentials you created.

## ownCloud LDAP-Config
The user_ldap app is shipped and enabled. However you need to configure LDAP manually in ownCloud because
the config is not portable. Use the local admin account (admin:admin).

LDAP-Parameters:
```
Uri:        ldap://ocis:9125
BindDN:     cn=konnectd,ou=sysusers,dc=example,dc=org
BindPW:     konnectd
BaseDN:     ou=users,dc=example,dc=org
Scope:      sub
Login Attr: cn
Email Attr: mail
Name Attr:  sn
UUID Attr:  uid
UUID Attr Type: text
Login Filter: (objectClass=posixaccount),
```
 
Run the user-sync:
```bash
docker-compose exec owncloud ./occ user:sync "OCA\User_LDAP\User_Proxy"
```

Glauth-schema: https://github.com/owncloud/ocis-glauth/blob/ff3ca75cd8748794d430e74769a65caa35998530/pkg/command/server.go#L162-L249

## Links
https://github.com/owncloud/openidconnect/blob/master/README.md
https://owncloud.github.io/ocis/bridge/
