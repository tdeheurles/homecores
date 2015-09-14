#!/bin/bash

# We take the cloud_config from the template and change the value
#  to the configed one

# Import config  and functions
. ./config.sh
. ./bootstrap_scripts/functions.sh

#public_ip_file_path="/home/core/configuration/cloud_config"

# name the variables
template_cloud_config_file="templates/template.cloud-config.yml"

unit_folder="templates/units"
template_units="$unit_folder/template.units"
etcd2_master="$unit_folder/unit.etcd2_master.service.yml"
flanneld="$unit_folder/unit.flanneld.service.yml"
kubectl="$unit_folder/unit.kubectl.service.yml"
kubelet="$unit_folder/unit.kubelet.service.yml"

cloud_config_file="auto_generated/cloud_config.yml"
units="auto_generated/units/main"
tmp="auto_generated/tmp"


echo "  Create files"
mkdir -p "auto_generated/units"
cp $template_cloud_config_file $cloud_config_file
cp $template_units             $units


echo "  Prepare units"
inject $etcd2_master $units "__ETCD2__"
inject $flanneld     $units "__FLANNEL__"
inject $kubectl      $units "__KUBECTL__"
inject $kubelet      $units "__KUBELET__"


echo "  Add units to cloud_config"
inject $units $cloud_config_file __UNITS__
sed -i "s|__ETCD2__||g" $cloud_config_file


echo "  Add environment variables"
sed -i "s|__PASSWORD__|$password|g"                         $cloud_config_file
sed -i "s|__ID_RSA__|$public_id_rsa|g"                      $cloud_config_file
sed -i "s|__HOSTNAME__|$coreos_hostname|g"                  $cloud_config_file
sed -i "s|__NETWORK_MASK__|$network_mask|g"                 $cloud_config_file
sed -i "s|__PUBLIC_IP_FILE_PATH__|$public_ip_file_path|g"   $cloud_config_file
sed -i "s|__FLANNEL_NETWORK__|$flannel_network|g"           $cloud_config_file
sed -i "s|__PROGRAMS_PATH__|$programs_path|g"               $cloud_config_file
sed -i "s|__KUBECTL_DOWNLOAD_URL__|$kubectl_download_url|g" $cloud_config_file


echo "  remove temporary files"
rm $tmp
