#! /usr/bin/bash

echo -e "\e[92mJoining Cluster\e[32m"

echo "Get config"
. /home/core/repository/homecores/auto_generated/coreos-config.sh

# prepare json parser
jq=$project_folder/tools/jq
chmod 755 $jq

# add ip to auto_generated
echo "Write auto_generated/ip"
echo "$public_ip" > auto_generated/ip




# ================ ETCD2 ================
# =======================================
echo "Adding etcd"

etcd_members_json=`curl --silent --max-time 2 $etcd_cluster_ip:2379/v2/members`
initial_cluster_table=`echo $etcd_members_json | jq '.members[] | "\(.name)=\(.peerURLs[0])"' | sed 's/"//g'`

cat <<EOF > etcd2.service
[Unit]
Description=etcd2

[Service]
ExecStart=/usr/bin/etcd2                            \
    -proxy                   on                     \
    -listen-client-urls      http://0.0.0.0:2379    \
    -initial-cluster         $initial_cluster_table

Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

sudo mv etcd2.service /etc/systemd/system/etcd2.service
sudo systemctl enable etcd2
sudo systemctl start etcd2


# =============== FLANNEL ===============
# =======================================
echo "Starting flanneld"
# cat <<EOF > flanneld.service
# [Service]
# Environment=FLANNEL_IFACE=$public_ip
# EOF
# mkdir -p /etc/systemd/system/flanneld.service.d/
# sudo mv flanneld.service /etc/systemd/system/flanneld.service.d/10-publicip.conf

cat <<EOF > options.env
FLANNELD_IFACE=$public_ip
EOF

sudo mkdir -p /run/flannel
sudo mv options.env /run/flannel/options.env
sudo systemctl start flanneld


# # ================ DOCKER ===============
# # =======================================
# echo "Restarting docker to use flannel network"
# source /run/flannel/subnet.env
# sudo rm /var/run/docker.pid
# sudo ifconfig docker0 ${FLANNEL_SUBNET}
# sudo docker daemon --bip=${FLANNEL_SUBNET} --mtu=${FLANNEL_MTU} &




# =============== KUBELET ===============
# =======================================
cat <<EOF > kubelet.service
[Unit]
Description=Kubernetes Kubelet
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStartPre=/usr/bin/mkdir -p /etc/kubernetes/manifests
ExecStart=/usr/bin/kubelet \
    --api-servers=http://192.168.1.13:8080 \
    --register-node=true \
    --allow-privileged=true \
    --config=/etc/kubernetes/manifests \
    --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# --api-servers= tells the kubelet the location of the apiserver.
# --kubeconfig tells kubelet where to find credentials to authenticate itself to the apiserver.
# --cloud-provider= tells the kubelet how to talk to a cloud provider to read metadata about itself.
# --register-node tells the kubelet to create its own node resource.

sudo mv kubelet.service /etc/systemd/system/kubelet.service
sudo systemctl enable kubelet
sudo systemctl start kubelet




# # =============== KUBECTL ===============
# # =======================================
# sudo cp $project_folder/templates/units/kubectl.target /etc/systemd/system/kubectl.target
# sudo systemctl enable kubectl.target
# sudo systemctl start kubectl.target



