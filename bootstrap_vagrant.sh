#! /bin/bash

mkdir -p auto_generated

if [[ ! -f config.sh ]]; then
	echo "you need to prepare the config.sh file first"
	echo "open config.sh"
	cp samples/sample.config.sh config.sh
	exit 1
fi

. ./config.sh

project_folder="/home/core/repository/homecores"
#public_network_to_use=`$path_to_virtual_box/VBoxManage.exe list bridgedifs | grep -e "\bName:\s*" | sed "s/\bName:\s*//g"`

echo "Prepare config for different services"
# config inside coreos
cat <<EOF > auto_generated/coreos-config.sh
coreos_hostname="$coreos_hostname"
shell_to_install="$shell_to_install"
password='$password'
id_rsa='$id_rsa'
discovery_token='$discovery_token'
image_kubernetes='$image_kubernetes'
network_mask="$network_mask"
user_data_file="$user_data_file"
project_folder="$project_folder"
atlas_token="$atlas_token"
local_test_cluster="$local_test_cluster"
etcd_cluster_ip="$etcd_cluster_ip"

cloud_config_template_file="templates/template.cloud-config.yml"
cloud_config_file="auto_generated/cloud-config.yml"
public_ip=\`ifconfig | grep \$network_mask | awk '{print \$2}'\`
EOF


# synced_folder
cat <<EOF  > auto_generated/vagrant_synced_folders.yaml
- name: default
  source: $current_project_folder
  destination: $project_folder
  nfs: true
  mount_options: 'nolock,vers=3,udp,noatime'
  disabled: false
EOF

# vagrant_config.rb
cat <<EOF > auto_generated/vagrant_config.rb
\$vm_memory             = $vm_memory
\$vm_cpus               = $vm_cpus
\$core_hostname         = "$coreos_hostname"
\$shell_to_install      = "$shell_to_install"
\$public_network_to_use = "$public_network_to_use"
\$local_test_cluster    = "$local_test_cluster"
EOF

vagrant global-status --prune
vagrant destroy -f && vagrant up && vagrant ssh
