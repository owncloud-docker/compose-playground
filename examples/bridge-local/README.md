# Run local bridge setup

## Setup

*   Add domains for ocis and oc10 to /etc/hosts

  `127.0.0.1  ocis.local`
  `127.0.0.1  oc10.local`

*   Start application stack

  `docker-compose up -d --build`
