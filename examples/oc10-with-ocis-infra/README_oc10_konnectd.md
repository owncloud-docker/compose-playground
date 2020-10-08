# oc10 ocis traefik deployment scenario 1

## Overview
ocis and oc10 running on a hcloud node behind traefik as reverse proxy
* Cloudflare DNS is resolving two domains
* Letsencrypt is providing a valid ssl certificate for both domains
* Traefik docker container terminates ssl and forwards https requests to ocis
* ocis docker container serves serves oidc provider konnectd to owncloud backend for authentification

## Node

### Requirements
* Server running Ubuntu 20.04 is public availible with a static ip address
* Two A-records for both domains is pointing on the servers ip address
* Create user `$sudo adduser username`
* Add user to sudo group `$sudo usermod -aG sudo username`
* Add users pub key to `~/.ssh/authorized_keys`
* Setup sshd to forbid root access and permit authorisation only by ssh key
* Install docker `$sudo apt install docker.io`
* Add user to docker group `$sudo usermod -aG docker username`
* Install docker-compose via `$ sudo curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose` (docker compose version 1.27.4 as of today)
* Make docker-compose executable `$ sudo chmod +x /usr/local/bin/docker-compose`
* Environment variables for OCIS Stack are provided by .env file

### Stack
The application stack consists out of five containers. The first one is a traefik proxy which is terminating ssl and forwards the https requests to the internal docker network. Additional, traefik is creating two certificates that are stored in `acme.json` in the folder `letsencrypt` of the users home directory.
The second container is the ocis server which is exposing the webservice on port 9200 to traefic and provides the oidc provider konnectd to owncloud.
oc10 is running as a three container setup out of owncloud-server, a db container and a redis con tainers as memcache storage.

### Config
Edit docker-compose.yml file to fit your domain setup

In this deployment scenario, traefik requests letsencrypt to issue 2 ssl certificates, so two certificate resolver are needed. One called ocis for the ocis container and one called oc10 for the oc10 container is a straight forward naming.
```
...
  traefik:
    image: "traefik:v2.2"
    container_name: "traefik"
    command:
      ...
      # Ocis certificate resolver
      - "--certificatesresolvers.ocis.acme.tlschallenge=true"
      - "--certificatesresolvers.ocis.acme.caserver=https://acme-v02.api.letsencrypt.org/directory"
      - "--certificatesresolvers.ocis.acme.email=user@${OCIS_DOMAIN}"
      - "--certificatesresolvers.ocis.acme.storage=/letsencrypt/acme-ocis.json"
      # OC10 certificate resolver
      - "--certificatesresolvers.oc10.acme.tlschallenge=true"
      - "--certificatesresolvers.oc10.acme.caserver=https://acme-v02.api.letsencrypt.org/directory"
      - "--certificatesresolvers.oc10.acme.email=user@${OCIS_DOMAIN}"
      - "--certificatesresolvers.oc10.acme.storage=/letsencrypt/acme-oc10.json"
...
```
It's important that the containers traefik label match with the correct resolver and domain
```
  ocis:
    ...
    labels:
      ...
      - "traefik.http.routers.ocis.rule=Host(`${OCIS_DOMAIN}`)"
      ...
```
```
  oc10:
    ...
    labels:
      ...
      - "traefik.http.routers.oc10.rule=Host(`${OC10_DOMAIN}`)"
      ...
```

A folder for letsencypt to store the certificate needs to be created
`$ mkdir ~/letsencrypt`
This folder is bind to the docker container and the certificate is persistently stored into it.

In this examnple, ssl shall be terminated from traefik and inside of the docker network, the services shall comunicate via http. For this `PROXY_TLS: "false"` as environment parameter for ocis has to be set.

For ocis to work properly it's neccesary to provide 2 config files.
Those files are delivered in the folder `ocis` of this repository which is bind into the ocis container.

Changes need to be done in identifier-registration.yml to match the domains
Phoenix client needs the redirects uri's set to the ocis domain while oc10 client needs them to be pointed on the owncloud domain

```
---
# OpenID Connect client registry.
clients:
  - id: phoenix
    name: OCIS
    application_type: web
    insecure: yes
    trusted: yes
    redirect_uris:
      - http://ocis.domain.com
      - http://ocis.domain.com/oidc-callback.html
      - https://ocis.domain.com/
      - https://ocis.domain.com/oidc-callback.html
    origins:
      - http://ocis.domain.com
      - https://ocis.domain.com

  - id: oc10
    name: OC10
    application_type: web
    secret: super
    insecure: yes
    trusted: yes
    redirect_uris:
      - https://oc10.domain.com/apps/openidconnect/redirect/
      - https://oc10.domain.com/apps/openidconnect/redirect
    origins:
      - http://oc10.domain.com
      - https://oc10.domain.com
```

The second file is the proxy-config.json which configures the ocis internal service proxy. CHanges are necessary to point onto the right urls for ocis and oc10.

```
{
  "HTTP": {
    "Namespace": "works.owncloud"
  },
  "policy_selector": {
    "static": {"policy" : "reva"}
  },
  "policies": [
    {
      "name": "reva",
      "routes": [
        {
          "endpoint": "/",
          "backend": "https://oc10.domain.com"
        },
        {
        ....
      ]
    },
    {
      "name": "oc10",
      "routes": [
        {
          "endpoint": "/",
          "backend": "https://ocis.domain.com"
        },
        ...
        {
          "endpoint": "/index.php/",
          "backend": "https://oc10.domain.com"
        }
      ]
    }
  ]
}
```


