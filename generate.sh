#! /bin/bash

. config.sh

cp $cloud_config_template_file $cloud_config_file

sed -i "s|__PASSWORD__|$password|g"                 $cloud_config_file
sed -i "s|__ID_RSA__|$id_rsa|g"                     $cloud_config_file
sed -i "s|__HOSTNAME__|$hostname|g"                 $cloud_config_file
sed -i "s|__DISCOVERY_TOKEN__|$discovery_token|g"   $cloud_config_file
sed -i "s|__IMAGE_KUBERNETES__|$image_kubernetes|g" $cloud_config_file
