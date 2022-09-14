ISTIO_VERSION=1.13.8

.PHONY: help init start deploy deploy-istio deploy-addons stop delete

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
	kubectl apply -k ./bootstrap

stop:
	minikube stop

delete:
	minikube delete

ip:
	@echo $(minikube_ip)

hosts:
	@echo "## add following lines to /etc/hosts:"
	@echo $(minikube_ip) kiali.example.com
	@echo $(minikube_ip) prom.example.com
