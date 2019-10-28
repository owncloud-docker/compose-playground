#!/usr/bin/env bash

occ config:app:set --value="http://localhost:9980/" onlyoffice DocumentServerUrl
occ config:app:set --value="http://onlyoffice/" onlyoffice DocumentServerInternalUrl
occ config:app:set --value="http://owncloud:${OWNCLOUD_PORT}/" onlyoffice StorageUrl