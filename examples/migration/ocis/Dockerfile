FROM smallstep/step-cli AS certgen

USER root
WORKDIR /home/step

RUN apk add --no-cache bash curl openssl
RUN mkdir konnectd_keys \
    && cd konnectd_keys \
    && step crypto jwk create 1-eddsa-ed25519.pub.json 1-eddsa-ed25519.key.json -kty OKP --crv Ed25519 --no-password --insecure \
    && step crypto keypair 1-rsa.pub 1-rsa.pem --kty RSA --size 4096 --no-password --insecure \
    && step crypto keypair 1-ecdsa-p-256.pub 1-ecdsa-p-256.pem --kty EC --curve P-256 --no-password --insecure \
    && openssl genpkey -algorithm RSA -out private-key.pem -pkeyopt rsa_keygen_bits:4096 \
    && openssl rand -out encryption.key 32 \
    && cd .. \
    && mkdir proxy_certs \
    && cd proxy_certs \
    && step certificate create localhost localhost.crt localhost.key --profile self-signed --subtle --san ocis --no-password --insecure

FROM owncloud/ocis:latest
COPY --from=certgen /home/step/ /

