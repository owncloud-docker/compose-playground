# Services

Additional services that can be included into the owncloud.

### ClamAV

Provides ClamAV via [mail/clamvav](https://github.com/Mailu/ClamAV)
Reachable via network at `clamav`

By default it uses `latest` as container tag, it can be overriden by `CLAMAV_CONTAINER_TAG`


### ElasticSearch

Provides ElasticSearch (5.6) based on the [official elastic search images] (https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html) provided by elastic.co.  
It will also directly install the [Ingest Attachment Processor Plugin](https://www.elastic.co/guide/en/elasticsearch/plugins/5.6/ingest-attachment.html)
required for `search_elastic` app to work properly

### OnlyOffice

Provides OnlyOffice based on the [official onlyoffice/documentserver image] (https://hub.docker.com/r/onlyoffice/documentserver)

Example to start it with ownCloud 10.0.10:
```
OWNCLOUD_RELEASE_DOCKER_TAG=10.0.10 \
docker-compose \
   -f owncloud-base.yml \
   -f owncloud-official.yml \
   -f services/onlyoffice.yml \
   -f services/onlyoffice-install.yml \
   -f services/onlyoffice-configure.yml \
   up
```

default port of owncloud is set to `8080` (changed from `80` since 10.0.10) but can be overriden by `OWNCLOUD_PORT`