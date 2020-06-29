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
ssh -t root@$IPADDR apt-get install -y git screen docker.io docker-compose
ssh -t root@$IPADDR git clone https://github.com/owncloud-docker/compose-playground.git
```

Anytime:
- Check IP `hcloud server ip $SERVER_NAME`
- Access `ssh root@IPADDR`

# Run

1. Access the hcloud machine or run localy ...
2. Set your domain or IP in .env 
3. Start via docker compose 

```
cd compose-playground/examples/eos-compose
echo "OCIS_DOMAIN=localhost" > .env
docker-compose up -d
```

# More commands

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

# Images 

can be found at https://github.com/owncloud-docker/eos-stack