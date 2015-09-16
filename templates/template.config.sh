# =================== USER CONFIGURATION ====================
# ===========================================================

# server name : use something like :
#  - vagrant: username-vm-coreos
#  - vagrant: username-bm-coreos
coreos_hostname="master1"
coreos_username="core"

# The mask of the local network used
network_mask="192.168.1"

# Uncomment the following to start as a master :
etcd_cluster_ip="192.168.1.1"

# Uncomment the following to start as a node :
# etcd_cluster_ip="192.168.1.x"
# master_hostname="master1"

# to simplify compatibility cygwin/windows
current_project_folder="c:/Users/username/repository/homecores"

# the network interface to use for virtualbox
public_network_to_use="Qualcomm Atheros AR8151 PCI-E Gigabit Ethernet Controller (NDIS 6.20)"



# ========================== OPTIONAL =======================
# ===========================================================
# Size of the CoreOS cluster created by Vagrant
vm_memory=4000
vm_cpus=1

# security
public_id_rsa=''

# shell to install (bash or zsh)
shell_to_install="bash"



# ======================= NOT USER CONF =====================
# === YOU DO NOT NEED TO GO BELOW THIS LINE NOT USER CONF ===
# ===========================================================
user_data_file="/var/lib/coreos-vagrant/vagrantfile-user-data"
project_folder="/home/core/repository/homecores"
programs_path="/home/core/programs"
public_ip_file_path="/home/core/configuration/cloud_config"
flannel_network="10.2.0.0/16"
initial_etcd_cluster="$master_hostname=http://$etcd_cluster_ip:2380"
kubernetes_version="1.0.4"
kubectl_download_url="https://storage.googleapis.com/kubernetes-release/release/v$kubernetes_version/bin/linux/amd64/kubectl"




# =============== KUBERNETES ON CoreOS GUIDE ================
# ===========================================================
 
# The IP address of the master node. 
# Worker nodes must be able to reach the master via this IP on port 443. 
# Additionally, external clients (such as an administrator using kubectl) 
#   will also need access, since this will run the Kubernetes API endpoint.
MASTER_IP=$etcd_cluster_ip

# List of etcd machines (http://ip:port), comma separated. 
# If you're running a cluster of 5 machines, list them all here.
ETCD_ENDPOINTS=$etcd_cluster_ip:2379

# The CIDR network to use for pod IPs. 
# Each pod launched in the cluster will be assigned an IP out of this range. 
# This network must be routable between all nodes in the cluster. 
# In a default installation, the flannel overlay network will provide routing to this network.
POD_NETWORK=$flannel_network

# The CIDR network to use for service cluster IPs. 
# Each service will be assigned a cluster IP out of this range. 
# This must not overlap with any IP ranges assigned to the POD_NETWORK, 
# or other existing network infrastructure. 
# Routing to these IPs is handled by a kube-proxy service local to each node, 
# and are not required to be routable between nodes.
SERVICE_IP_RANGE=10.3.0.0/24
SERVICE_IP_RANGE_MASK=10.3.0

# The IP address of the Kubernetes API Service. 
# If the SERVICE_IP_RANGE is changed above, 
# this must be set to the first IP in that range.
K8S_SERVICE_IP=$SERVICE_IP_RANGE_MASK.1

# The IP address of the cluster DNS service. 
# This IP must be in the range of the SERVICE_IP_RANGE and cannot be the first IP in the range. This same IP must be configured on all worker nodes to enable DNS service discovery.
DNS_SERVICE_IP=$SERVICE_IP_RANGE_MASK.10



# ============== CERTIFICATES =================
# =============================================
CERTIFICATE_PATH="certificates"

CA_KEY_PEM_NAME="ca-key.pem"

CA_PEM_NAME="ca.pem"
OPENSSL_CNF_NAME="$CERTIFICATE_PATH/openssl.cnf"
APISERVER_KEY_PEM_NAME="$CERTIFICATE_PATH/apiserver-key.pem"
APISERVER_CSR_NAME="$CERTIFICATE_PATH/apiserver.csr"
APISERVER_PEM_NAME="$CERTIFICATE_PATH/apiserver.pem"
WORKER_KEY_PEM_NAME="$CERTIFICATE_PATH/worker-key.pem"
WORKER_CSR_NAME="$CERTIFICATE_PATH/worker.csr"
WORKER_PEM_NAME="$CERTIFICATE_PATH/worker.pem"
ADMIN_KEY_PEM_NAME="$CERTIFICATE_PATH/admin-key.pem"
ADMIN_CSR_NAME="$CERTIFICATE_PATH/admin.csr"
ADMIN_PEM_NAME="$CERTIFICATE_PATH/admin.pem"

CA_PEM="$CERTIFICATE_PATH/$CA_PEM_NAME"
CA_KEY_PEM="$CERTIFICATE_PATH/$CA_KEY_PEM_NAME"
OPENSSL_CNF="$CERTIFICATE_PATH/$OPENSSL_CNF_NAME"
APISERVER_KEY_PEM="$CERTIFICATE_PATH/$APISERVER_KEY_PEM_NAME"
APISERVER_CSR="$CERTIFICATE_PATH/$APISERVER_CSR_NAME"
APISERVER_PEM="$CERTIFICATE_PATH/$APISERVER_PEM_NAME"
WORKER_KEY_PEM="$CERTIFICATE_PATH/$WORKER_KEY_PEM_NAME"
WORKER_CSR="$CERTIFICATE_PATH/$WORKER_CSR_NAME"
WORKER_PEM="$CERTIFICATE_PATH/$WORKER_PEM_NAME"
ADMIN_KEY_PEM="$CERTIFICATE_PATH/$ADMIN_KEY_PEM_NAME"
ADMIN_CSR="$CERTIFICATE_PATH/$ADMIN_CSR_NAME"
ADMIN_PEM="$CERTIFICATE_PATH/$ADMIN_PEM_NAME"
KUBERNETES_SSL_PATH="/etc/kubernetes/ssl"
