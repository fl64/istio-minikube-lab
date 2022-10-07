ISTIO_VERSION=1.13.8

.PHONY: help init start deploy deploy-istio deploy-addons stop delete

minikube_ip := $(shell minikube ip)
istio_ingress_ip := $(shell kubectl get -n istio-system svc istio-ingressgateway -o json | jq .status.loadBalancer.ingress[0].ip -r)

default: help;

help:
	echo halp

init:
	curl -L https://istio.io/downloadIstio | ISTIO_VERSION=${ISTIO_VERSION} TARGET_ARCH=x86_64 sh -

start:
	minikube start --kubernetes-version=v1.23.6 --memory=8196 --cpus=4
	minikube addons enable storage-provisioner
	minikube addons enable default-storageclass
	minikube addons enable metrics-server
	minikube addons enable metallb

deploy:
	kubectl apply -k apps/

undeploy:
	kubectl delete -k apps/

istio-deploy:
	# ./istio-${ISTIO_VERSION}/bin/istioctl manifest install --set profile=default -y
	kubectl create namespace istio-system || true
	helm upgrade --install  istio-operator ./istio-${ISTIO_VERSION}/manifests/charts/istio-operator -n istio-system

istio-bootstap:
	kubectl apply -f ./istio-${ISTIO_VERSION}/samples/addons/prometheus.yaml
	kubectl apply -f ./istio-${ISTIO_VERSION}/samples/addons/kiali.yaml
	kubectl apply -k ./bootstrap

istio-undeploy:
	kubectl delete -f ./istio-${ISTIO_VERSION}/samples/addons/prometheus.yaml
	kubectl delete -f ./istio-${ISTIO_VERSION}/samples/addons/kiali.yaml
	kubectl delete -k ./bootstrap
	helm uninstall -n istio-system istio-operator

stop:
	minikube stop

delete:
	minikube delete

info:
	@echo minikube ip:
	@echo $(minikube_ip)
	@echo istio ingress ip:
	@echo $(istio_ingress_ip)
	istioctl pc -n istio-system routes $(kubectl get pods -n istio-system -l app=istio-ingressgateway -o json | jq  .items[0].metadata.name -r )

hosts:
	@echo "## add following lines to /etc/hosts:"
	@echo $(istio_ingress_ip) echo.k8s.example.com
	@echo $(istio_ingress_ip) echo.istio.example.com
	@echo $(istio_ingress_ip) kiali.example.com
	@echo $(istio_ingress_ip) prom.example.com
