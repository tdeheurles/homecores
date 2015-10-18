# -*- mode: ruby -*-
# vi: set ft=ruby :

# We take the cloud_config from the template and change the value
#  to the configed one

# name the variables
template_cloud_config_file = './templates/template.cloud-config.yml'
unit_folder                = './templates/units'
files_folder               = './templates/coreos_files'
cloud_config_file          = './auto_generated/cloud_config.yml'


FileUtils.copy(template_cloud_config_file, cloud_config_file)


inject_file "#{unit_folder}/unit.write_public_ip.service.yml", cloud_config_file, '__WRITE_PUBLIC_IP__'
if (defined? $master_hostname) == nil
	inject_file "#{unit_folder}/unit.etcd2_master.service.yml", cloud_config_file, '__ETCD2__'
	inject_file "#{unit_folder}/unit.kubelet_master.service.yml", cloud_config_file, '__KUBELET__'
	inject_file "#{unit_folder}/unit.kubectl_master.service.yml", cloud_config_file, '__KUBECTL__'
else
	inject_file "#{unit_folder}/unit.etcd2_node.service.yml", cloud_config_file, '__ETCD2__'
	inject_file "#{unit_folder}/unit.kubelet_node.service.yml", cloud_config_file, '__KUBELET__'
	inject_file "#{unit_folder}/unit.kubectl_node.service.yml", cloud_config_file, '__KUBECTL__'
end
inject_file "#{unit_folder}/unit.flanneld.service.yml", cloud_config_file, '__FLANNEL__'
inject_file "#{unit_folder}/unit.docker.service.yml", cloud_config_file, '__DOCKER__'


inject_file "#{files_folder}/file.write_ip.yml", cloud_config_file, '__FILE_WRITE_IP__'
inject_file "#{files_folder}/file.sed_kubernetes_public_ip.yml", cloud_config_file, '__FILE_WRITE_FLANNEL_PUBLIC_IP__'
inject_file "#{files_folder}/file.write_flannel_public_ip.yml", cloud_config_file, '__FILE_SED_KUBERNETES_PUBLIC_IP__'


inject cloud_config_file, '__USERNAME__',                $coreos_username
inject cloud_config_file, '__ID_RSA__',                  $public_id_rsa
inject cloud_config_file, '__HOSTNAME__',                $coreos_hostname
inject cloud_config_file, '__NETWORK_MASK__',            $network_mask
inject cloud_config_file, '__MAIN_CONFIGURATION_PATH__', $main_configuration_path
inject cloud_config_file, '__FLANNEL_NETWORK__',         $flannel_network
inject cloud_config_file, '__PROGRAMS_PATH__',           $programs_path
inject cloud_config_file, '__KUBECTL_DOWNLOAD_URL__',    $kubectl_download_url
inject cloud_config_file, '__DNS_SERVICE_IP__',          $dns_service_ip

if (defined? $master_hostname) == nil
  inject cloud_config_file, '__ETCD_CLIENT_ENDPOINTS__', 'http://${PUBLIC_IP}:2379'
  inject cloud_config_file, '__ETCD_PEER_ENDPOINTS__',   "#{$master_hostname}=http://${PUBLIC_IP}:2380"
  inject cloud_config_file, '__MASTER_HOSTNAME__',       $coreos_hostname
  inject cloud_config_file, '__MASTER_IP__',             '${PUBLIC_IP}'
else
  inject cloud_config_file, '__ETCD_CLIENT_ENDPOINTS__', "http://#{$etcd_cluster_ip}:2379"
  inject cloud_config_file, '__ETCD_PEER_ENDPOINTS__',   "#{$master_hostname}=http://#{$etcd_cluster_ip}:2380"
  inject cloud_config_file, '__MASTER_HOSTNAME__',       $master_hostname
  inject cloud_config_file, '__MASTER_IP__',             $etcd_cluster_ip
end

inject cloud_config_file, '__KUBERNETES_SSL_PATH__',     $kubernetes_ssl_path
inject cloud_config_file, '__WORKER_PEM_NAME__',         $worker_pem_name
inject cloud_config_file, '__WORKER_KEY_PEM_NAME__',     $worker_key_pem_name
inject cloud_config_file, '__CA_PEM_NAME__',             $ca_pem_name
inject cloud_config_file, '__ADMIN_KEY_PEM_NAME__',      $admin_key_pem_name
inject cloud_config_file, '__ADMIN_PEM_NAME__',          $admin_pem_name


