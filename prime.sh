#!/bin/bash

set -e

IS_AWAKE=false

while [ $IS_AWAKE == false ]; do
    set +e
    RESULT=$(curl -so /dev/null -w '%{http_code}' "$CONSUL_URL/v1/status/leader")
    set -e
    if [ "$RESULT" == "200" ]; then
        echo "Consul awake at $(date "+%Y-%m-%d %H:%M:%S")"
        IS_AWAKE=true
    else
        echo "Consul not awake yet $(date "+%Y-%m-%d %H:%M:%S")"
        sleep 1
    fi
done

printenv | while read -r line
do
    IFS='=' read -r -a ARR <<< "$line"
    KEY="${ARR[0]}"
    if [ "$KEY" != "CONSUL_URL" ]; then
        VALUE="${!KEY}"
        curl -s -X PUT -d "$VALUE" "$CONSUL_URL/v1/kv/$KEY"
    fi
done

curl -s -X PUT -d "true" "$CONSUL_URL/v1/kv/IS_CONSUL_PRIMED"