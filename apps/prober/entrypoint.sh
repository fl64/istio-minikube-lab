#!/usr/bin/env bash
: ${JQ_QUERY:="{ host: .env.HOSTNAME, cluster: .env.cluster,  ver: .env.version }"}
while true; do
  d=$(date +"%H:%M:%S")
  echo "[ ${d} ] ========================================================================="
  echo QUERY: ${JQ_QUERY}
  echo "GET Service: ${SERVICE_TO_CURL} "
  curl --max-time 10 --connect-timeout 3 -sq -XGET "${SERVICE_TO_CURL}" | jq "${JQ_QUERY}" -c
  echo "POST Service: ${SERVICE_TO_CURL} "
  curl --max-time 10 --connect-timeout 3 -sq -XPOST "${SERVICE_TO_CURL}" | jq "${JQ_QUERY}" -c
  sleep ${SLEEP_TIMEOUT:-3}
done
