# Run local bridge setup

## Setup

* Add domains for ocis and oc10 to `/etc/hosts`

  ```
  127.0.0.1  ocis.local
  127.0.0.1  oc10.local
  ```

* Configure environment variables for docker-compose

  eg. create a `.env` file with following content
  ```
  OC10_DOMAIN=oc10.local
  OCIS_DOMAIN=ocis.local
  ``` 


* Start application stack

  `docker-compose up -d --build`

## Usage

* Visit https://ocis.local to see ocis and https://oc10.local to see oc10

* Visit http://localhost:8080 to see the traefik dashboard

## Known Limitations

* login to ocis is not working due following error:
  ```
  ocis_1     | 2020-11-05T16:23:31Z ERR identifier failed to logon with backend error="ldap identifier backend logon connect error: LDAP Result Code 1 \"Operations Error\": " service=konnectd
  ```