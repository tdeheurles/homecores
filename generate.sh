#! /bin/bash

# This script need to be run inside coreos.
# We first install a version and then update de cloud-config

. config.sh

cp $cloud_config_template_file $cloud_config_file

ip_public=`ifconfig | grep 192.168 | awk '{print $2}'`

sed -i "s|__PASSWORD__|$password|g"                 $cloud_config_file
sed -i "s|__ID_RSA__|$id_rsa|g"                     $cloud_config_file
sed -i "s|__HOSTNAME__|$hostname|g"                 $cloud_config_file
sed -i "s|__DISCOVERY_TOKEN__|$discovery_token|g"   $cloud_config_file
sed -i "s|__IMAGE_KUBERNETES__|$image_kubernetes|g" $cloud_config_file
sed -i "s|__IP_PUBLIC__|$ip_public|g"               $cloud_config_file
