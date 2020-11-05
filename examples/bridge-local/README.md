# Run local bridge setup

## Setup

*   Add domains for ocis and oc10 to /etc/hosts

  `127.0.0.1  ocis.local`
  `127.0.0.1  oc10.local`

*   Create devcerts
  `cd ./traefik/devcerts/`
  `mkcert ocis.local`
  `mkcert oc10.local`
  `mkcert -install`

*   Start application stack

  `docker-compose up -d --build`

Visit ocis.local to get ocis served and oc10.local to get oc10 served
Visit ocis.local:8080 to see the traefik dashboard