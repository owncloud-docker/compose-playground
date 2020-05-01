# IDP

Provides Integration with using a idp


## SimpleSaml

**Important**: For simplesaml to currently work, it is necessary to have the following hostnames set in `/etc/hosts`

```
127.0.0.1       owncloud.test
127.0.0.1       idp
```
Additionally be aware, that the ports for the `idp` are 80/443 and the owncloud ports can currently not be changed
This is a known limitation and needs to be addressed later

- `simplesaml.yml`  
   Provides simplesaml via [jnyryan/simplesamlphp](https://hub.docker.com/r/jnyryan/simplesamlphp/). 
   It uses the `latest` version by default - can be overriden by `SIMPLESAML_CONTAINER_TAG`
   While it provides the basic build block for simplesaml in the composable-infrastructure, 
   a apache-configuration and a auth-source is required to fully integrate with owncloud
   
   
##### ownCloud apache configurations

- `simplesaml-apache-aliases.yml`..
... Apache configuration allowing access to owncloud via `/owncloud`
... Shibboleth protected access is via `/oc-shib`

- `simplesaml-apache-basic.yml`..
... Configuration that protects all routes

- `simplesaml-apache-oauth.yml`..
... Configuration that is proposed to superseed `simplesaml-apache-basic.yml` at some point.
... It only protects the `/login` route via shibboleth

#### simplesam auth backends

- `simplesaml-auth-basic.yml`  
   Provides a simple username:password backend to simplesaml for testing
   Login details can be configured via `simlesamlphp/config/authsources.php` - check `basicauth` provide
   By default two accounts are provided: `student:studentpass` and `employee:employeepass`
   
   

- `simplesaml-auth-ldap.yml`  
   Integrates the openldap container provided in the composable infrastructure