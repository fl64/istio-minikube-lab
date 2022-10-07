#!/usr/bin/env bash
istio_pod=$(kubectl get pods -n istio-system -l app=istio-ingressgateway -o json | jq  .items[0].metadata.name -r )
istioctl pc -n istio-system all ${istio_pod}
istioctl pc -n istio-system ep ${istio_pod}

# istioctl pc -n istio-system routes $(kubectl get pods -n istio-system -l app=istio-ingressgateway -o json | jq  .items[0].metadata.name -r )
