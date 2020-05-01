# compose-playground for ocis

This repository provides different docker-compose yaml files acting as various "infrastructure components".

The aim of these components is, to provide an easy way of setting up owncloud with different infrastrucutre scenarions.

For example, we want to run a *ocis* combined with *redis*.
This could be done by using the following `docker-compose` statement:

```bash
docker-compose \
    -f ocis.yml \
    -f ../cache/redis-ocis.yml \
    up
```
