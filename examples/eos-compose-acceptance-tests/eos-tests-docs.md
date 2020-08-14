### EOS setup
To run the tests With Eos locally, you will first need to start the OCIS server with the EOS storage backend.
Before setup you will want to change to this branch: https://github.com/owncloud/ocis/pull/409 on the ocis server if it is not merged.
In the testrunner side you will want to be on this branch https://github.com/owncloud/core/pull/37796.

The setup is done using docker-compose. The docker-compose file is in the [ocis](https://github.com/owncloud/ocis) repo. 
To run the setup you can check the documentation in https://owncloud.github.io/ocis/eos/. Keep in mind the commands in the documentation are out  of date, so use these commands instead
``` bash
cd <to ocis-repo>
docker-compose up -d
# run the ldap server so the container can resolve system users from ocis
docker-compose exec ocis /start-ldap

# Check the user accounts are resolved correctly
docker-compose exec ocis id einstein

# Restart the ocis services to work with EOS backend
docker-compose exec ocis ./bin/ocis kill reva-users
docker-compose exec ocis ./bin/ocis run reva-users
docker-compose exec ocis ./bin/ocis kill reva-storage-home
docker-compose exec -e REVA_STORAGE_EOS_LAYOUT="{{substr 0 1 .Id.OpaqueId}}/{{.Id.OpaqueId}}" -e REVA_STORAGE_HOME_DRIVER=eoshome ocis ./bin/ocis run reva-storage-home
docker-compose exec ocis ./bin/ocis kill reva-storage-home-data
docker-compose exec -e REVA_STORAGE_EOS_LAYOUT="{{substr 0 1 .Id.OpaqueId}}/{{.Id.OpaqueId}}" -e REVA_STORAGE_HOME_DATA_DRIVER=eoshome ocis ./bin/ocis run reva-storage-home-data
docker-compose exec ocis ./bin/ocis kill reva-frontend
docker-compose exec -e DAV_FILES_NAMESPACE="/eos/" ocis ./bin/ocis run reva-frontend
```

If you want to check the logs for ocis you can check them using this command
```bash
cd <to-ocis-repo>
docker-compose logs -f -t --tail=250 ocis
```

***note***: sometimes the setup doesn't work properly. If that happens you will not be able to upload any file, the server just returns 401. In that case just shut down the docker-compose setup with
```bash
cd <to-ocis-repo>
docker-compose down
```
And then start from the beginning.

### Running tests
To run the tests with eos you can use this command
``` bash
cd <to-oc10-core-repo>

make test-acceptance-api \
TEST_SERVER_URL=https://localhost:9200 \
TEST_OCIS=true \
BEHAT_FILTER_TAGS='~@skipOnOcis&&~@local_storage&&~@skipOnOcis-EOS-Storage&&~@notToImplementOnOCIS&&~@toImplementOnOCIS' \
SKELETON_DIR=apps/testing/data/apiSkeleton \
EXPECTED_FAILURES_FILE=/<to-ocis-repo>/tests/acceptance/expected-failures.txt \
DELETE_USER_DATA_CMD='docker exec -it mgm-master eos -r 0 0 rm -r /eos/dockertest/reva/users/%s' \
BEHAT_FEATURE=tests/acceptance/apiSuite/test.feature
```
### some useful tips
1. To check the user accounts created and available in ocis
```
cd <to-ocis-repo>
docker-compose exec ocis bash

# goes to the bash shell inside the container
cd /var/tmp/ocis-accounts/accounts

# do ls to check the files available in the directory
ls

# Example:
# [root@ocis accounts]# ls
# 4c510ada-c86b-4815-8820-42cdf82c3d51  820ba2a1-3f54-4538-80a4-2d73007e30bf  932b4540-8d16-481e-8ef4-588e4b6b151c  Alice  bc596f3c-c955-4328-80a0-60d018b4ad57  f7fbf8c8-139b-4376-b307-cf0a8c2d0d9c

# to check the content of the users do
cat Alice | jq

## Example:
# [root@ocis accounts]# cat Alice | jq
# {
#   "id": "Alice",
#   "accountEnabled": true,
#   "displayName": "Alice Hansen",
#   "preferredName": "Alice",
#   "uidNumber": "40040",
#   "gidNumber": "30000",
#   "mail": "alice@example.org",
#   "passwordProfile": {
    "password": "$6$Q2xohBXok9qorrIo$ssR/jgxzsncuDu51uiT2pFNLhmCdUIOLRSVO9k2swapFM10HTK35GKQ8c2k2E.Ap01oM/fIjFpeXoyxjpFifg/"
#   },
#   "onPremisesSamAccountName": "Alice"
# }

## You will see all the attributes of the user
```

2. To check the files of the user in the EOS storage backend
``` bash
cd <to-ocis-repo>

❯ docker-compose exec ocis eos ls /eos/dockertest/reva/users/A/Alice
FOLDER
PARENT
textfile0.txt
textfile1.txt
textfile2.txt
textfile3.txt
textfile4.txt
welcome.txt
```
Note that the files are stored in the the this layout: `/eos/dockertest/reva/users/<First letter of user id>/<user id>`


### running tests on the CI
for running the tests on the CI we have a PR at https://github.com/owncloud/ocis/pull/370
In theory if we just replicate the docker-compose setup we use locally, that should also work in the CI.
But there seems to be some problem. The EOS services are not starting up normally in CI. that needs to be looked into in detail.

