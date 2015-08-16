#! /bin/bash

. config.sh

cloud_config_file="auto_generated/cloud-config.yml"

cp     templates/template.cloud-config.yml     $cloud_config_file

public_ip=`ifconfig | grep $network_mask | awk '{print $2}'`

echo "Generating cloud-config for $public_ip"

sed -i "s|__PASSWORD__|$password|g"                 $cloud_config_file
sed -i "s|__ID_RSA__|$id_rsa|g"                     $cloud_config_file
sed -i "s|__HOSTNAME__|$coreos_hostname|g"          $cloud_config_file
sed -i "s|__DISCOVERY_TOKEN__|$discovery_token|g"   $cloud_config_file
sed -i "s|__IMAGE_KUBERNETES__|$image_kubernetes|g" $cloud_config_file
sed -i "s|__IP_PUBLIC__|$public_ip|g"               $cloud_config_file

echo " "
echo -e "\e[94mwill restart\e[39m"
echo " "
coreos-cloudinit -validate=true --from-file $cloud_config_file && sudo cp $cloud_config_file $user_data_file && sudo reboot
