#!/usr/bin/env bash
set -x

METADATA_FILE_NAME=$(date +%s | sha256sum | base64 | head -c 32)
METADATA_FILE="/tmp/${METADATA_FILE_NAME}"

echo "Creating metadata file"
curl http://localhost/Shibboleth.sso/Metadata --silent --output "${METADATA_FILE}"

echo "Fixing metadata file"
sed -i -e "s/localhost/${OWNCLOUD_SHIB_HOST}:${OWNCLOUD_SHIB_PORT}/g" "${METADATA_FILE}"

echo "Uploading Metadata"
curl -include --form "userfile=@${METADATA_FILE}" --form "filename=${METADATA_FILE_NAME}" https://www.testshib.org/procupload.php --silent

