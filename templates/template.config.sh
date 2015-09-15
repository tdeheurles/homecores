# Size of the CoreOS cluster created by Vagrant
vm_memory=4000
vm_cpus=1

# server name : use something like :
#  - vagrant: username-vm-coreos
#  - vagrant: username-bm-coreos
coreos_hostname="coreos-username"

# shell to install (bsh or zsh)
shell_to_install="bash"

# The mask of the local network used
network_mask="192.168.1"

# If no cluster is provided, the VM will 
#   start as a master
#   etcd_cluster_ip="" for starting a new cluster master
etcd_cluster_ip=""

# to simplify compatibility cygwin/windows
current_project_folder="c:/Users/username/repository/homecores"

# the network interface to use for virtualbox
# TODO: add help here
public_network_to_use="Qualcomm Atheros AR8151 PCI-E Gigabit Ethernet Controller (NDIS 6.20)"

# Uncomment one of the following
#   BareMetal :
#user_data_file="/var/lib/coreos-install/user_data"
#   Vagrant :
user_data_file="/var/lib/coreos-vagrant/vagrantfile-user-data"

# security
public_id_rsa=''


# Not user conf
# ===============
project_folder="/home/core/repository/homecores"
flannel_network="10.200.0.0/16"
programs_path="/home/core/programs"
kubectl_download_url="https://storage.googleapis.com/kubernetes-release/release/v1.0.3/bin/linux/amd64/kubectl"
public_ip_file_path="/home/core/configuration/cloud_config"
