ISTIO_VERSION=1.13.8

.PHONY: start stop delete init deploy undeploy hosts lint

minikube_ip := $(shell minikube ip)
default: help;

help:
	echo halp

init:
	curl -L https://istio.io/downloadIstio | ISTIO_VERSION=${ISTIO_VERSION} TARGET_ARCH=x86_64 sh -

start:
	minikube start --kubernetes-version=v1.23.6 --memory=8196 --cpus=4
	minikube addons enable ingress
	minikube addons enable storage-provisioner
	minikube addons enable default-storageclass
	minikube addons enable metrics-server
	minikube addons enable metallb

deploy:
	kubectl apply -k apps/

deploy-istio:
	./istio-${ISTIO_VERSION}/bin/istioctl manifest install --set profile=default -y

deploy-addons:
	kubectl apply -f ./istio-${ISTIO_VERSION}/samples/addons/prometheus.yaml
	kubectl apply -f ./istio-${ISTIO_VERSION}/samples/addons/kiali.yaml

kiali:
	helm install \
  --namespace istio-system \
  --set auth.strategy="anonymous" \
  --repo https://kiali.org/helm-charts \
  kiali-server \
  kiali-server

stop:
	minikube stop

delete:
	minikube delete
