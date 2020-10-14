# OCIS 2 node deployment scenario

ocis and a idp setup with each service running on an individual node

## Overview
Each node is a Ubuntu 20.04 VM on HCloud from Hetzner. The nodes are configured to provide a docker compose stack. Each node has a domain pointing on it and provides end to end encryption by using a SSL Certificate from Letsencrypt.
The two domains `ocis-node.owncloud.works` and `idp-node.owncloud.works` are registered at Cloudflare DNS with an A record pointing to the ip and a CAA record that has to provide the Certificate authority for both domains.

## Scenario content
The example contains 2 folders which provide a docker-compose.yml file for both nodes. The idpnode folder contains a config folder that is providing a identifier-registration config for the allowed clients.

## Nodes

### Requirements
* docker
* docker-compose
* Environment variables for OCIS Stack
  * `export OCIS_DOMAIN=ocis-node.owncloud.works`
  * `export IDP_DOMAIN=idp-node.owncloud.works`

## OCIS Node

### Stack
The application stack contains two containers. The first one is traefik which is terminating https requests and forwards the requests to the internal docker network. Additional, traefik is creating a certificate that is stored in `acme.json` in the folder `letsencrypt` of the users home directory.
The second one is ocis which is exposing the webservice on port 9200 to traefic and next to traefik the ldap interface of the glauth service via port 9125.

### Config
When running a traefik as reverse proxy in front of ocis, its important to switch of the certificate creation of ocis internal service proxy.
This can be done by `PROXY_TLS: "false"` as environment parameter for ocis.

Adding a user to the account service can be done via commandline.
`docker exec -it ocis sh`
`ocis accounts add --preferred-name bob --on-premises-sam-account-name bob --displayname "Bob" --uidnumber 33333 --gidnumber 30000 --password 123456 --mail bob@example.org --enabled`
After having setup the idp node, the user credentials can be used for login to ocis.

## IDP Node

### Stack
The application stack is pretty similar and also contains two containers. The first one is traefik which is terminating https requests and forwards the requests to the internal docker network. Traefik is also creating a certificate that is stored in `acme.json` in the folder `letsencrypt` of the users home directory.
The service container serves konnectd which is acting as idp for ocis on the ocisnode. konnectd needs a user repository which is provided by ocis via ldap protocol on port 9125. Ocis-glauth service exposes this ldap interface for ocis-accounts service.

### Config
As there is no proxy behind traefik on the idp node, only the ldap scheme on ocis needs to be configured.

    LDAP_URI: ldap://ocis-node.owncloud.works:9125
    LDAP_BINDDN: cn=konnectd,ou=sysusers,dc=example,dc=org
    LDAP_BINDPW: konnectd
    LDAP_BASEDN: ou=users,dc=example,dc=org
    LDAP_SCOPE: sub
    LDAP_LOGIN_ATTRIBUTE: cn
    LDAP_EMAIL_ATTRIBUTE: mail
    LDAP_NAME_ATTRIBUTE=: n
    LDAP_UUID_ATTRIBUTE: uid
    LDAP_UUID_ATTRIBUTE_TYPE: text
    LDAP_FILTER: (objectClass=posixaccount)
