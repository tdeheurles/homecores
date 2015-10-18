# =================== USER CONFIGURATION ====================
# ===========================================================

# server name :
#  - this just need to be different for every virtual machine
$coreos_hostname="master1"

# The mask of the local network used
$network_mask="192.168.1"

# the network interface to use for virtualbox
#   refer to the README.md for information on how to get it
$public_network_to_use="Qualcomm Atheros AR8151 PCI-E Gigabit Ethernet Controller (NDIS 6.20)"



# ========================== OPTIONAL =======================
# ===========================================================
# Size of the CoreOS cluster created by Vagrant
$vm_memory=4000
$vm_cpus=1

# security
$public_id_rsa='AAAAB3NzaC1yc2EAAAADAQABAAACAQDStSONzQfb5YSK/ImXvyXf6CU8wuybrSsVBFv2XbTQ3R5q3hOx5s4JTEU+yA9yDK4RtfsGJJ28brWHfGM+dEkxfK2CvIND7YcU8gMHe+bfQCr5cuLM8j5eYHqDYKwDLuSZLZEvL+/CBW74p4LmD9HFTH+Z0+QDYjX7isHk8UImUR/kAzlvDW/QCpCwa/oFKBzfA66hBgRv8ASw1Nih9AbuBtLUB1i7BfRNJpEb7/qszQljFWrkVdXRjwDq+tx663u6H1yzWjJXb9+twBumsxuIJxr2NLOCMzI6NIcdsyps6AN4Lza1TAG7HqiinDUwFAD3bJo6V840RLx5p8QcsX1zfNxN4ZhVu40tgLOoVQqwbjOEoFrAOtempzkZNrCoXmHc3jCD68XazU5RICMqriGnRa0xx/WzV1/MidvRZIg7MZEFzrRoZp+EyiQqfrCH7NgLX6IGfcsccGi2fbvlF28gNZ4d8cgEC0fiv62XfmKm91u0RtS0r2GvnthtDiSHWopX1PAJ+CMLCfo8rxZv4G8Iu88o+JRS4tsgHw9IAsa1lsH7ZECuRwwG0VeiOF+6jbUYCW6G+0Ldv2v6C5FupV2NghhSMJP7rGDRmRr0oD5MZi36u+2NaLpwn6qsAFc4EewJFjmwGYnLZTvHL7HN1Jcf8ZV6/w/g48Qx7YUYOi4nAw== homecores@example.com'

# shell to install (bash or zsh)
$shell_to_install="bash"

# Path to the certificates
$CERTIFICATE_PATH="demo_certificates"



# ============================ NODE =========================
# ===========================================================
# Uncomment the following to start as a node
# etcd_cluster_ip="192.168.1.51"
# master_hostname="master1"





# ======================= NOT USER CONF =====================
# === YOU DO NOT NEED TO GO BELOW THIS LINE NOT USER CONF ===
# ===========================================================

$coreos_username="core"
$user_data_file="/var/lib/coreos-vagrant/vagrantfile-user-data"
$project_folder="/home/core/repository/homecores"
$programs_path="/home/core/programs"
$main_configuration_path="/home/core/configuration/cloud_config"
$flannel_network="10.2.0.0/16"
$initial_etcd_cluster="$master_hostname=http://$etcd_cluster_ip:2380"
$kubernetes_version="1.0.6"
$kubectl_download_url="https://storage.googleapis.com/kubernetes-release/release/v$kubernetes_version/bin/linux/amd64/kubectl"




# =============== KUBERNETES ON CoreOS GUIDE ================
# ===========================================================
 
# The IP address of the master node. 
# Worker nodes must be able to reach the master via this IP on port 443. 
# Additionally, external clients (such as an administrator using kubectl) 
#   will also need access, since this will run the Kubernetes API endpoint.
$MASTER_IP=$etcd_cluster_ip

# List of etcd machines (http://ip:port), comma separated. 
# If you're running a cluster of 5 machines, list them all here.
$ETCD_ENDPOINTS="$etcd_cluster_ip:2379"

# The CIDR network to use for pod IPs. 
# Each pod launched in the cluster will be assigned an IP out of this range. 
# This network must be routable between all nodes in the cluster. 
# In a default installation, the flannel overlay network will provide routing to this network.
$POD_NETWORK=$flannel_network

# The CIDR network to use for service cluster IPs. 
# Each service will be assigned a cluster IP out of this range. 
# This must not overlap with any IP ranges assigned to the POD_NETWORK, 
# or other existing network infrastructure. 
# Routing to these IPs is handled by a kube-proxy service local to each node, 
# and are not required to be routable between nodes.
$SERVICE_IP_RANGE="10.3.0.0/24"
$SERVICE_IP_RANGE_MASK="10.3.0"

# The IP address of the Kubernetes API Service. 
# If the SERVICE_IP_RANGE is changed above, 
# this must be set to the first IP in that range.
$K8S_SERVICE_IP="$SERVICE_IP_RANGE_MASK.1"

# The IP address of the cluster DNS service. 
# This IP must be in the range of the SERVICE_IP_RANGE and cannot be the first IP in the range. This same IP must be configured on all worker nodes to enable DNS service discovery.
$DNS_SERVICE_IP="$SERVICE_IP_RANGE_MASK.10"



# ============== CERTIFICATES =================
# =============================================

$CA_PEM_NAME="ca.pem"
$CA_KEY_PEM_NAME="ca-key.pem"
$OPENSSL_CNF_NAME="openssl.cnf"
$APISERVER_KEY_PEM_NAME="apiserver-key.pem"
$APISERVER_CSR_NAME="apiserver.csr"
$APISERVER_PEM_NAME="apiserver.pem"
$WORKER_KEY_PEM_NAME="worker-key.pem"
$WORKER_CSR_NAME="worker.csr"
$WORKER_PEM_NAME="worker.pem"
$ADMIN_KEY_PEM_NAME="admin-key.pem"
$ADMIN_CSR_NAME="admin.csr"
$ADMIN_PEM_NAME="admin.pem"

$CA_PEM="$CERTIFICATE_PATH/$CA_PEM_NAME"
$CA_KEY_PEM="$CERTIFICATE_PATH/$CA_KEY_PEM_NAME"
$OPENSSL_CNF="$CERTIFICATE_PATH/$OPENSSL_CNF_NAME"

$APISERVER_KEY_PEM="$CERTIFICATE_PATH/$APISERVER_KEY_PEM_NAME"
$APISERVER_CSR="$CERTIFICATE_PATH/$APISERVER_CSR_NAME"
$APISERVER_PEM="$CERTIFICATE_PATH/$APISERVER_PEM_NAME"

$WORKER_KEY_PEM="$CERTIFICATE_PATH/$WORKER_KEY_PEM_NAME"
$WORKER_CSR="$CERTIFICATE_PATH/$WORKER_CSR_NAME"
$WORKER_PEM="$CERTIFICATE_PATH/$WORKER_PEM_NAME"

$ADMIN_KEY_PEM="$CERTIFICATE_PATH/$ADMIN_KEY_PEM_NAME"
$ADMIN_CSR="$CERTIFICATE_PATH/$ADMIN_CSR_NAME"
$ADMIN_PEM="$CERTIFICATE_PATH/$ADMIN_PEM_NAME"

$KUBERNETES_SSL_PATH="/etc/kubernetes/ssl"
