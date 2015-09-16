#!/bin/bash

# We take the cloud_config from the template and change the value
#  to the configed one

# Import config  and functions
. ./config.sh
. ./bootstrap_scripts/functions.sh

# name the variables
template_cloud_config_file="templates/template.cloud-config.yml"
unit_folder="templates/units"
cloud_config_file="auto_generated/cloud_config.yml"
tmp="auto_generated/tmp"
files_folder="templates/coreos_files"


echo "  Create files and folders"
mkdir -p "auto_generated/units"
cp $template_cloud_config_file $cloud_config_file


echo "  Add units to cloud_config"
. ./config.sh
inject   $unit_folder/unit.write_public_ip.service.yml    $cloud_config_file "__WRITE_PUBLIC_IP__"
if [[ $master_hostname == "" ]];then
	inject $unit_folder/unit.etcd2_master.service.yml     $cloud_config_file "__ETCD2__"
    inject $unit_folder/unit.kubelet_master.service.yml   $cloud_config_file "__KUBELET__"
	inject $unit_folder/unit.kubectl_master.service.yml   $cloud_config_file "__KUBECTL__"
else
 	inject $unit_folder/unit.etcd2_node.service.yml       $cloud_config_file "__ETCD2__"
    inject $unit_folder/unit.kubelet_node.service.yml     $cloud_config_file "__KUBELET__"
	inject $unit_folder/unit.kubectl_node.service.yml     $cloud_config_file "__KUBECTL__"
fi
inject $unit_folder/unit.flanneld.service.yml             $cloud_config_file "__FLANNEL__"
inject $unit_folder/unit.docker.service.yml               $cloud_config_file "__DOCKER__"


echo "  Add files to cloud_config"
inject $files_folder/file.write_ip.yml                    $cloud_config_file "__FILE_WRITE_IP__"
inject $files_folder/file.sed_kubernetes_public_ip.yml    $cloud_config_file "__FILE_WRITE_FLANNEL_PUBLIC_IP__"
inject $files_folder/file.write_flannel_public_ip.yml     $cloud_config_file "__FILE_SED_KUBERNETES_PUBLIC_IP__"


echo "  Add environment variables"
sed -i "s|__USERNAME__|$coreos_username|g"                        $cloud_config_file
sed -i "s|__ID_RSA__|$public_id_rsa|g"                            $cloud_config_file
sed -i "s|__HOSTNAME__|$coreos_hostname|g"                        $cloud_config_file
sed -i "s|__NETWORK_MASK__|$network_mask|g"                       $cloud_config_file
sed -i "s|__MAIN_CONFIGURATION_PATH__|$main_configuration_path|g" $cloud_config_file
sed -i "s|__FLANNEL_NETWORK__|$flannel_network|g"                 $cloud_config_file
sed -i "s|__PROGRAMS_PATH__|$programs_path|g"                     $cloud_config_file
sed -i "s|__KUBECTL_DOWNLOAD_URL__|$kubectl_download_url|g"       $cloud_config_file
sed -i "s|__DNS_SERVICE_IP__|$DNS_SERVICE_IP|g"                   $cloud_config_file

if [[ $master_hostname == "" ]]; then
	sed -i 's|__ETCD_CLIENT_ENDPOINTS__|http://${PUBLIC_IP}:2379|g'                 $cloud_config_file
	sed -i "s|__ETCD_PEER_ENDPOINTS__|$master_hostname=http://\${PUBLIC_IP}:2380|g" $cloud_config_file
	sed -i "s|__MASTER_HOSTNAME__|$coreos_hostname|g"                               $cloud_config_file
	sed -i 's|__MASTER_IP__|${PUBLIC_IP}|g'                                         $cloud_config_file
else
    sed -i "s|__ETCD_CLIENT_ENDPOINTS__|http://$etcd_cluster_ip:2379|g"                $cloud_config_file
    sed -i "s|__ETCD_PEER_ENDPOINTS__|$master_hostname=http://$etcd_cluster_ip:2380|g" $cloud_config_file
	sed -i "s|__MASTER_HOSTNAME__|$master_hostname|g"                                  $cloud_config_file
 	sed -i "s|__MASTER_IP__|$etcd_cluster_ip|g"                                        $cloud_config_file
fi

sed -i "s|__KUBERNETES_SSL_PATH__|$KUBERNETES_SSL_PATH|g"  $cloud_config_file
sed -i "s|__WORKER_PEM_NAME__|$WORKER_PEM_NAME|g"          $cloud_config_file
sed -i "s|__WORKER_KEY_PEM_NAME__|$WORKER_KEY_PEM_NAME|g"  $cloud_config_file
sed -i "s|__CA_PEM_NAME__|$CA_PEM_NAME|g"                  $cloud_config_file
sed -i "s|__ADMIN_KEY_PEM_NAME__|$ADMIN_KEY_PEM_NAME|g"    $cloud_config_file
sed -i "s|__ADMIN_PEM_NAME__|$ADMIN_PEM_NAME|g"            $cloud_config_file



echo "  remove temporary files"
rm $tmp

