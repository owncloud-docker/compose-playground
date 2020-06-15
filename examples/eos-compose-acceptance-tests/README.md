# EOS for oCIS

# Setup

Setup on hcloud cx21 and install some dependencies (imho needs cx21 to have enough ram for building ocis)

First check for correct hcloud project: `hcloud context list'

```
# set your name here for labels and ssh-key setup
ME=$(whoami) 
SERVER_NAME=eos-ocis-test

# create server
hcloud server create --type cx21 --image ubuntu-20.04 --ssh-key $ME --name $SERVER_NAME --label owner=$ME --label for=test --label from=eos-compose

IPADDR=$(hcloud server ip $SERVER_NAME)

ssh -t root@$IPADDR apt-get update -y
ssh -t root@$IPADDR apt-get install -y git screen docker.io docker-compose ldap-utils
ssh -t root@$IPADDR git clone https://github.com/owncloud-docker/compose-playground.git
ssh -t root@$IPADDR "cd compose-playground/examples/eos-compose-acceptance-tests && ./build"
```

Anytime:
- Check IP `hcloud server ip $SERVER_NAME`
- Access `ssh root@IPADDR`

# Run

1. Access the hcloud machine or run localy ...
2. Set your domain or IP in .env 
3. Start via docker compose 

```
echo "OCIS_DOMAIN=localhost" > .env
docker-compose up -d
```

# Run tests
## zero-config
```
docker run \
--env-file=config/eos-docker.env \
--net=testnet \
-e BEHAT_FEATURE="<feature>" \
--rm eos/testrunner:latest
```

## with local test-runner
```
make test-acceptance-api \
DELETE_USER_DATA_CMD='docker exec -it mgm-master eos rm -r /eos/dockertest/reva/users/%s' \
TEST_SERVER_URL=https://localhost:9200 \
TEST_EXTERNAL_USER_BACKENDS=true \
TEST_OCIS=true \
BEHAT_FILTER_TAGS='~@skipOnOcis&&~@skipOnLDAP&&@TestAlsoOnExternalUserBackend&&~@local_storage' \
SKELETON_DIR=apps/testing/data/apiSkeleton \
BEHAT_FEATURE='<feature>'
```

# More commands

add users for manual testing
```
ldapadd -x -D "cn=admin,dc=owncloud,dc=com" -w admin -H ldap://localhost -f ./config/example-ldap-users-groups.ldif
```

In the mgm-master or ocis container you can access eos cli

```
eos vid ls
eos whoami
eos -r 0 0 whoami
eos -r 2 2 whoami
eos -r 20000 30000 whoami

eos -r 0 0 ls -la /eos/dockertest/reva/users
```

Also see file `check` for more system checks.

# Limitations

- in LDAP the `cn` field has to match the `uid` field
- the display name for the user is taken from the `sn` field in LDAP
- when trying to share in phoenix, a list of avatars is shown, but no names of the users/groups
