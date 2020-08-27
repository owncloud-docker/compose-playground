# ocis-haproxy
OCIS fullstack with haproxy. Does not use the built in proxy. NOT FOR PRODUCTION!

## Install

Generate haproxy certs

````$ ./install-certs.sh````

This will download mkcert-tool, install a development root-ca in your system, and create a dev-cert for haproxy. Mkcert 
will prompt for your sudo password to install the dev-ca in your truststore. If you don`t trust this process
you can do the steps manually.

```
$ wget -O mkcert https://github.com/FiloSottile/mkcert/releases/download/v1.4.1/mkcert-v1.4.1-linux-amd64
$ mkcert -install
$ mkcert localhost
$ cat localhost.pem localhost-key.pem > ./certs/localhost-comb.pem
```

## Run
```
docker-compose up
```

## Use

- https://localhost:9200 => Entrypoint
- https://localhost:8404/stats => HAProxy Stats

### Credentials
```
einstein:relativity
marie:radioactivity
```

### Docs
https://owncloud.github.io/
