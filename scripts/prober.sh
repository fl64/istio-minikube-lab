#!/usr/bin/env bash

while true; do
  curl -sq http://echo.k8s.example.com/ -H "x-v2-header: v2" | jq .env
  curl -sq http://echo.istio.example.com/ -H "x-v2-header: v2" | jq .env
  sleep 1
done
