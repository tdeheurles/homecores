#! /bin/bash

# This script need to be run inside coreos.
# We first install a version and then update de cloud-config

. ./config.sh

cp $cloud_config_template_file $cloud_config_file

echo "Generating cloud-config for $public_ip"

sed "s|__PASSWORD__|$password|g"                 $cloud_config_file > $cloud_config_file
sed "s|__ID_RSA__|$id_rsa|g"                     $cloud_config_file > $cloud_config_file
sed "s|__HOSTNAME__|$coreos_hostname|g"          $cloud_config_file > $cloud_config_file
sed "s|__DISCOVERY_TOKEN__|$discovery_token|g"   $cloud_config_file > $cloud_config_file
sed "s|__IMAGE_KUBERNETES__|$image_kubernetes|g" $cloud_config_file > $cloud_config_file
sed "s|__IP_PUBLIC__|$public_ip|g"               $cloud_config_file > $cloud_config_file

