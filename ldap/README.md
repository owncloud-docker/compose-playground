## Different LDAP providers

### OpenLDAP 

OpenLdap is currently using the docker-image provided by [osixia/docker-openldap](https://github.com/osixia/docker-openldap)


The directory `openldap-ldif` contains ldif files for preseeding the ldap server.  
To mount a file, include the `openldap-mount-ldif.yml` (by default it will include `openldap-lid/base.ldif`)
To define a different file, define `LDIF_FILE` environment variable.

**example**:
```
LDIF_FILE=/path/to/my/file.ldif docker-compose -f owncloud-base.yml -f ldap/openldap.yml -f ldap/openldap-mount-ldif.yml
```
  

More information on using ldif files with the container: [osixia/docker-openldap#seed-ldap-database-with-ldif](https://github.com/osixia/docker-openldap#seed-ldap-database-with-ldif)


