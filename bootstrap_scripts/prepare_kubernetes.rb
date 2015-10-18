# -*- mode: ruby -*-
# vi: set ft=ruby :


destination = 'auto_generated/kubernetes'

unless File.exist?(destination)
	FileUtils.mkdir destination
end

if (defined? $master_hostname) == nil
	# APISERVER
	template_apiserver = 'templates/kubernetes/manifest.kube-apiserver.yml'
	target_apiserver   = "#{destination}/kube-apiserver.yml"
  FileUtils.copy template_apiserver, target_apiserver

  inject target_apiserver, '__ETCD_ENDPOINTS__',         "http://__PUBLIC_IP__:2379"
	inject target_apiserver, '__FLANNEL_NETWORK__',        $flannel_network
  inject target_apiserver, '__K8S_VERSION__',            $kubernetes_version
  inject target_apiserver, '__SERVICE_IP_RANGE__',       $service_ip_range
  inject target_apiserver, '__APISERVER_PEM_NAME__',     $apiserver_pem_name
  inject target_apiserver, '__APISERVER_KEY_PEM_NAME__', $apiserver_key_pem_name
  inject target_apiserver, '__CA_PEM_NAME__',            $ca_pem_name
  inject target_apiserver, '__KUBERNETES_SSL_PATH__',    $kubernetes_ssl_path


	# CONTROLLER-MANAGER
	template_controller = 'templates/kubernetes/manifest.kube-controller.yml'
	target_controller   = "#{destination}//kube-controller.yml"
  FileUtils.copy template_controller, target_controller

  inject target_controller, '__K8S_VERSION__',            $kubernetes_version
  inject target_controller, '__APISERVER_KEY_PEM_NAME__', $apiserver_key_pem_name
  inject target_controller, '__CA_PEM_NAME__',            $ca_pem_name
  inject target_controller, '__KUBERNETES_SSL_PATH__',    $kubernetes_ssl_path


	# SCHEDULER
	template_scheduler = 'templates/kubernetes/manifest.kube-scheduler.yml'
	target_scheduler   = "#{destination}//kube-scheduler.yml"
  FileUtils.copy template_scheduler, target_scheduler

  inject target_scheduler, '__K8S_VERSION__', $kubernetes_version
	

	#   KUBE-PROXY
	template_proxy = 'templates/kubernetes/manifest.kube-proxy_master.yml'
	target_proxy   = "#{destination}/kube-proxy.yml"
  FileUtils.copy template_proxy, target_proxy

  inject target_proxy, '__K8S_VERSION__', $kubernetes_version

else
	#   KUBE-PROXY
	template_proxy = 'templates/kubernetes/manifest.kube-proxy_node.yml'
	target_proxy   = "#{destination}/kube-proxy.yml"
  FileUtils.copy template_proxy, target_proxy

  inject target_proxy, '__K8S_VERSION__',         $kubernetes_version
  inject target_proxy, '__KUBERNETES_SSL_PATH__', $KUBERNETES_SSL_PATH
  inject target_proxy, '__MASTER_IP__',           $etcd_cluster_ip


	#   KUBECONFIG
	template_kubeconfig = 'templates/kubernetes/manifest.node_kubeconfig.yml'
	target_kubeconfig   = "#{destination}/node_kubeconfig.yml"
  FileUtils.copy  template_kubeconfig, target_kubeconfig

  inject target_kubeconfig, '__KUBERNETES_SSL_PATH__', $kubernetes_ssl_path
  inject target_kubeconfig, '__CA_PEM__',              $ca_pem_name
  inject target_kubeconfig, '__WORKER_PEM__',          $worker_pem_name
  inject target_kubeconfig, '__WORKER_KEY_PEM__',      $worker_key_pem_name
end


