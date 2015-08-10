#! /bin/bash

. ./auto_generated/coreos-config.sh

cp $cloud_config_template_file $cloud_config_file

echo "Generating cloud-config for $public_ip"

sed "s|__PASSWORD__|$password|g"                 $cloud_config_file > $cloud_config_file
sed "s|__ID_RSA__|$id_rsa|g"                     $cloud_config_file > $cloud_config_file
sed "s|__HOSTNAME__|$coreos_hostname|g"          $cloud_config_file > $cloud_config_file
sed "s|__DISCOVERY_TOKEN__|$discovery_token|g"   $cloud_config_file > $cloud_config_file
sed "s|__IMAGE_KUBERNETES__|$image_kubernetes|g" $cloud_config_file > $cloud_config_file
sed "s|__IP_PUBLIC__|$public_ip|g"               $cloud_config_file > $cloud_config_file

echo " "
echo -e "\e[94mwill restart\e[39m"
echo -e "\e[94mtry to connect in a minute with :\e[39m"
echo " "
echo -e "        \e[92mssh core@$public_ip\e[39m"
echo " "
coreos-cloudinit -validate=true --from-file $cloud_config_file && sudo cp $cloud_config_file $user_data_file && sudo reboot
