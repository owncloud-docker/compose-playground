# Database

Provides different databases to be combined with owncloud

## Mariadb

Uses the official [dockerhub mariadb](https://hub.docker.com/_/mariadb/) image.
By default with tag `10.1` - override with `DOCKER_MARIADB_TAG`

## Mysql

Uses the official [dockerhub mysql](https://hub.docker.com/_/mysql/) image.
By default with tag `latest` - override with `DOCKER_MYSQL_TAG`

## Postgres

Uses the official [dockerhub postgres](https://hub.docker.com/_/postgres/) image.
By default with tag `9.6` - override with `DOCKER_POSTGRES_TAG`

## Oracle

Users a intermediate oracle 11 container. Currently no further options are available
Startup times are around 3-5 minutes - please be more patient when bootstrapping an oracle environment