#!/usr/bin/env bash
while true; do
  d=$(date +"%H:%M:%S")
  echo "[ ${d} ] ========================================================================="
  echo "Service: ${SERVICE_TO_CURL}"
  curl --max-time 10 --connect-timeout 3 -sq -XGET "${SERVICE_TO_CURL}" -H "x-v2-header: v2" | jq '{ host: .env.HOSTNAME, cluster: .env.cluster,  ver: .env.version }' -c
  sleep ${SLEEP_TIMEOUT:-1}
done
