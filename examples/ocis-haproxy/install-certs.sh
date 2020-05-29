#!/usr/bin/env bash

if [[ "$OSTYPE" == "linux-gnu" ]]; then
        MKCERT_URL=https://github.com/FiloSottile/mkcert/releases/download/v1.4.1/mkcert-v1.4.1-linux-amd64
elif [[ "$OSTYPE" == "darwin"* ]]; then
        MKCERT_URL=https://github.com/FiloSottile/mkcert/releases/download/v1.4.1/mkcert-v1.4.1-darwin-amd64
else
        echo "Could not determine os, please download mkcert manually at https://github.com/FiloSottile/mkcert/releases"
        exit 1
fi

echo "Downloading mkcert"
wget -O mkcert ${MKCERT_URL}
chmod +x ./mkcert

echo "Installing development CA in to system-trust:"
./mkcert -install

echo "Generating test-certificate"
./mkcert localhost

echo "Merging cert and private-key.."
cat localhost.pem localhost-key.pem > ./certs/localhost-comb.pem
rm localhost.pem && rm localhost-key.pem

echo "Done! Run docker-compose up to proceed"