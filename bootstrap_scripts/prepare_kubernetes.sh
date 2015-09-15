#!/bin/bash

. ./config.sh

kubernetes_master="templates/template.kubernetes.master.yaml"
kubernetes_node="templates/template.kubernetes.node.yaml"
target="auto_generated/kubernetes.yaml"

if [[ $etcd_cluster_ip == "" ]];then
	# master
	cp $kubernetes_master $target
else
	# node
 	cp $kubernetes_node $target
fi

sed -i "s|__FLANNEL_NETWORK__|$flannel_network|g"  $target
sed -i "s|__K8S_VERSION__|$kubernetes_version|g"  $target
