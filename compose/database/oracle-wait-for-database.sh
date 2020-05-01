#!/usr/bin/env bash
sqlplus=/usr/lib/oracle/12.2/client64/bin/sqlplus

# increase timeout for wait for oracle by default

wait_for_oracle() {
    local host_name="${1}"
    if ! grep -q ":" <<< "${host_name}"
    then
        host_name="${host_name}:1521"
    fi
    local result

    echo "wait-for-oracle: waiting ${OWNCLOUD_DB_TIMEOUT} seconds for ${host_name}"
    for i in $(seq "${OWNCLOUD_DB_TIMEOUT}"); do
        # disabled to not abort testing the connection
        set +eo pipefail

        echo "QUIT" | $sqlplus -L "${OWNCLOUD_DB_USERNAME}/${OWNCLOUD_DB_PASSWORD}@${host_name}/${OWNCLOUD_DB_NAME}" | grep "Connected to:" > /dev/null 2>&1
        result=$?

        # reenable pipefail
        set -eo pipefail

        if [ ${result} -eq 0 ] ; then
            echo "wait-for-oracle: ${host_name} available after ${i} seconds"
            break
        fi
        sleep 1
    done
    if [ ! ${result} -eq 0 ] ; then
        echo "wait-for-oracle: timeout - ${host_name} still not available after ${OWNCLOUD_DB_TIMEOUT} seconds"
        exit 1
    fi

}

wait_for_oracle "${OWNCLOUD_DB_HOST}"
true