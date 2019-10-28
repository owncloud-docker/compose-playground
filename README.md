# compose-playground

This repository provides different docker-compose yaml files acting as various "infrastructure components".

The aim of these components is, to provide an easy way of setting up owncloud with different infrastrucutre scenarions.

For example, we want to run a *owncloud* combined with *redis*, *mariadb* and *ldap*.
This could be done by using the following `docker-compose` statement:

```
docker-compose \
    -f owncloud-base.yml \
    -f owncloud-official.yml \
    -f cache/redis.yml \
    -f database/mariadb.yml \
    -f ldap/openldap.yml \
    -f ldap/openldap-mount-ldif.yml \
    up
```

## Layout

The root folder contains various owncloud components:

- `owncloud-base.yml`  
  entrypoint and compose yml to be included for all setups
  
- `owncloud-official.yml`  
  use the official [owncloud/server](https://hub.docker.com/r/owncloud/server) image
  default docker tag: `latest` - override via `OWNCLOUD_RELEASE_DOCKER_TAG` by setting to [one of the tag values](https://hub.docker.com/r/owncloud/server/tags/)
  
- `owncloud-official-mount-core.yml`
  mounts a local owncloud folder inside the container. 
  by default the folder `./owncloud` is mounted, it can be customized via `OWNCLOUD_FOLDER`
  default docker tag: `latest` - override via `OWNCLOUD_BASE_DOCKER_TAG`
  
- `owncloud-exported-ports.yml`
  export ports to be accessible locally.  
  by default the ports `9680` (http) and `9643` (https) are exported.   
  ports can be customized via `OWNCLOUD_HTTPS_PORT` and `OWNCLOUD_HTTP_PORT`

## Examples:

Some examples for starting different infrastructures

- *owncloud*, *redis*, *postgres*  
  ```
  docker-compose \
      -f owncloud-base.yml \
      -f owncloud-official.yml \
      -f cache/redis.yml \
      -f database/postgres.yml \
      up
  ```  
  
  
- *owncloud*, *redis*, *postgres*, *samba share*  
  ```
  docker-compose \
      -f owncloud-base.yml \
      -f owncloud-official.yml \
      -f cache/redis.yml \
      -f database/postgres.yml \
      -f storage/samba.yml \
      up
  ```
  
- *owncloud*, *redis*, *mariadb*, *scality objestorage as primary storage*
  ```
  docker-compose \
      -f owncloud-base.yml \
      -f owncloud-official.yml \
      -f cache/redis.yml \
      -f database/mariadb.yml \
      -f storage/scality-primary-objectstore.yml \
      up
  ```
    
- *owncloud*, *exported ports*, *redis*, *mariadb*, *clamav*, *files_antivirus (daemon mode)*
  ```
  docker-compose \
      -f owncloud-base.yml \
      -f owncloud-official.yml \
      -f owncloud-exported-ports.yml \
      -f cache/redis.yml \
      -f database/mariadb.yml \
      -f services/clamav.yml \
      -f configs/enable_files_antivirus_daemon.yml \
      up -d
  ```
  

- Example using environment variables to set up a server with objectstore using a custom server folder and a custom apps folder:
  *custom owncloud*, *apps*, *exported ports*, *redis*, *mariadb*, *scality objestorage as primary storage*

```
  OWNCLOUD_FOLDER={owncloud server folder path} \
  OWNCLOUD_APPS_FOLDER={extra apps to be enabled folder path} \
  OWNCLOUD_LICENSE_KEY={any valid keys} \
  docker-compose \

    -f owncloud-base.yml \
    -f owncloud-mount-core.yml \
    -f owncloud-mount-apps.yml \
    -f owncloud-exported-ports.yml \
    -f cache/redis.yml \
    -f database/mariadb.yml \
    -f storage/scality.yml \
    -f storage/scality-primary-objectstore.yml \
  up
```

In order to run several stacks in the same host we can use the -p option of docker-compose this way and they will run independently:

```
docker compose -p project1 -f .... up/down

docker compose -p project2 -f .... up/down
```

