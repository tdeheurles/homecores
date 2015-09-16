#!/bin/bash

. ./config.sh

echo "  Prepare kubernetes manifests"
destination="auto_generated/kubernetes"
mkdir -p $destination
if [[ $master_hostname == "" ]]; then
	# APISERVER
	echo "    apiserver"
	template_apiserver="templates/kubernetes/manifest.kube-apiserver.yml"
	target_apiserver="$destination/kube-apiserver.yml"
	cp $template_apiserver $target_apiserver

	sed -i 's|__ETCD_ENDPOINTS__|http://__PUBLIC_IP__:2379|g'       $target_apiserver
	sed -i "s|__FLANNEL_NETWORK__|$flannel_network|g"               $target_apiserver
	sed -i "s|__K8S_VERSION__|$kubernetes_version|g"                $target_apiserver
	sed -i "s|__SERVICE_IP_RANGE__|$SERVICE_IP_RANGE|g"             $target_apiserver
	sed -i "s|__APISERVER_PEM_NAME__|$APISERVER_PEM_NAME|g"         $target_apiserver
	sed -i "s|__APISERVER_KEY_PEM_NAME__|$APISERVER_KEY_PEM_NAME|g" $target_apiserver
	sed -i "s|__CA_PEM_NAME__|$CA_PEM_NAME|g"                       $target_apiserver
	sed -i "s|__KUBERNETES_SSL_PATH__|$KUBERNETES_SSL_PATH|g"       $target_apiserver


	# CONTROLLER-MANAGER
	echo "    controller-manager"
	template_controller="templates/kubernetes/manifest.kube-controller.yml"
	target_controller="$destination/kube-controller.yml"
	cp $template_controller $target_controller
	
	sed -i "s|__K8S_VERSION__|$kubernetes_version|g"                $target_controller
	sed -i "s|__APISERVER_KEY_PEM_NAME__|$APISERVER_KEY_PEM_NAME|g" $target_controller
	sed -i "s|__CA_PEM_NAME__|$CA_PEM_NAME|g"                       $target_controller
	sed -i "s|__KUBERNETES_SSL_PATH__|$KUBERNETES_SSL_PATH|g"       $target_controller


	# SCHEDULER
	echo "    scheduler"
	template_scheduler="templates/kubernetes/manifest.kube-scheduler.yml"
	target_scheduler="$destination/kube-scheduler.yml"
	cp $template_scheduler $target_scheduler
	
	sed -i "s|__K8S_VERSION__|$kubernetes_version|g"           $target_scheduler
	

	#   KUBE-PROXY
	echo "    proxy"
	template_proxy="templates/kubernetes/manifest.kube-proxy_master.yml"
	target_proxy="$destination/kube-proxy.yml"
	cp $template_proxy $target_proxy
	
	sed -i "s|__K8S_VERSION__|$kubernetes_version|g"      $target_proxy

else
	#   KUBE-PROXY
	echo "    proxy"
	template_proxy="templates/kubernetes/manifest.kube-proxy_node.yml"
	target_proxy="$destination/kube-proxy.yml"
	cp $template_proxy $target_proxy
	
	sed -i "s|__K8S_VERSION__|$kubernetes_version|g"          $target_proxy	
	sed -i "s|__KUBERNETES_SSL_PATH__|$KUBERNETES_SSL_PATH|g" $target_proxy
	sed -i "s|__MASTER_IP__|$etcd_cluster_ip|g"               $target_proxy


	#   KUBECONFIG
	echo "    kubeconfig"
	template_kubeconfig="templates/kubernetes/manifest.node_kubeconfig.yml"
	target_kubeconfig="$destination/node_kubeconfig.yml"
	cp $template_kubeconfig $target_kubeconfig

	sed -i "s|__KUBERNETES_SSL_PATH__|$KUBERNETES_SSL_PATH|g" $target_kubeconfig
	sed -i "s|__CA_PEM__|$CA_PEM_NAME|g"                      $target_kubeconfig
	sed -i "s|__WORKER_PEM__|$WORKER_PEM_NAME|g"              $target_kubeconfig
	sed -i "s|__WORKER_KEY_PEM__|$WORKER_KEY_PEM_NAME|g"      $target_kubeconfig
fi


