# BAREMETAL / VAGRANT
# ===================
# server name : use something like :
#  - vagrant: username-vm-coreos
#  - vagrant: username-bm-coreos
coreos_hostname="forget-hostname-coreos"

# cluster
atlas_token=''

# security
password=''
id_rsa=''

# Uncomment one of the following
#   BareMetal :
#user_data_file="/var/lib/coreos-install/user_data"
#   Vagrant :
user_data_file="/var/lib/coreos-vagrant/vagrantfile-user-data"

# The mask of the local network used
network_mask="192.168.1"




# VAGRANT ONLY
# ============
# Size of the CoreOS cluster created by Vagrant
vm_memory=5000
vm_cpus=1

# shell to install (bsh or zsh)
shell_to_install="bash"


# to simplify compatibility cygwin/windows
current_project_folder="c:/Users/username/repository/homecores"

public_network_to_use="Qualcomm Atheros AR8151 PCI-E Gigabit Ethernet Controller (NDIS 6.20)"

# Virtual box folder
#path_to_virtual_box="C:/Program\ Files/Oracle/VirtualBox"

# DEPRECATED
# ==========
discovery_token=''

# kubernetes
image_kubernetes='gcr.io/google_containers/hyperkube:v1.0.1'
