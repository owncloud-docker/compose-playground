# EOS for oCIS

Set your domain or IP in .env and start compose file

```
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

