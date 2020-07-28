# UCS in Docker

## Run 

```
docker run -d -it --name ucs \
    --hostname=ucs \
    -e domainname=ucs.ocis.local \
    -e rootpwd=pass \
    -p 8011:80 \
    -p 389:389 \
    -p 7389:7389 \
    -e container=docker \
    -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
    -v $PWD/profile:/var/cache/univention-system-setup/profile \
    --tmpfs /run --tmpfs /run/lock \
    --cap-add=SYS_ADMIN \
    --restart unless-stopped \
    univention/ucs-master-amd64 /sbin/init
```

The profile provides a basic auto-config, finish configuration with:

```
docker exec -ti ucs /usr/lib/univention-system-setup/scripts/setup-join.sh
```

Now you can access the ucs ldap via:

```
docker exec -ti ucs ldapsearch -x -b "dc=ocis,dc=local" -H ldap://127.0.0.1 -D "uid=Administrator,cn=users,dc=ocis,dc=local" -W "objectclass=*"

ldapsearch -x -b "dc=ocis,dc=local" -H ldap://localhost -D "uid=Administrator,cn=users,dc=ocis,dc=local" -W "objectclass=*"
```