#! /bin/bash

. config.sh

input_file="template.cloud-config.yml"
out_file="cloud-config.yml"

cp $input_file $out_file

sed -i "s|__PASSWORD__|$password|g"                 $out_file
sed -i "s|__ID_RSA__|$id_rsa|g"                     $out_file
sed -i "s|__HOSTNAME__|$hostname|g"                 $out_file
sed -i "s|__DISCOVERY_TOKEN__|$discovery_token|g"   $out_file
sed -i "s|__IMAGE_KUBERNETES__|$image_kubernetes|g" $out_file
