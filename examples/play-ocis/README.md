# Example for local oCIS with configured IP / Domain

Deploy oCIS binary with redis via docker-compose. 

To configure your IP or domain change the docker-compose.yml
- KONNECTD_ISS: https://ocis.local:9200
- PHOENIX_OIDC_AUTHORITY: https://ocis.local:9200
- PHOENIX_OIDC_METADATA_URL: https://ocis.local:9200/.well-known/openid-configuration
- PHOENIX_WEB_CONFIG_SERVER: https://ocis.local:9200
- REVA_OIDC_ISSUER: https://ocis.local:9200

And the add the uri to phoenix section in config/identifier-registration.yml

```
        redirect_uris:
          - https://ocis.local:9200/
          - https://ocis.local:9200/oidc-callback.html
        origins:
          - https://ocis.local:9200
```

## Build

Generated using composable infrastructure, this can be done like this:

```bash
mkdir examples/play-ocis
cp -r compose/ocis/* examples/play-ocis/
cp -r compose/cache/redis-ocis.yml examples/play-ocis/
cd examples/play-ocis/
export OCIS_BASE_URL=ocis.local
docker-compose -f ocis.yml -f redis-ocis.yml config  > docker-compose.yml
sed -i -e "s|your-url|${OCIS_BASE_URL}|g" config/identifier-registration.yml
```

The remaining files ocis.yaml and redis-ocis.yml are not needed anymore, but could show you later what you were starting with.

## Run

Add domain "ocis.local" to your /etc/hosts (only once)

```bash
echo "127.0.0.1 ocis.local" >> /etc/hosts
```

```bash
docker-compose up -d
```

open browser at https://ocis.local:9200

