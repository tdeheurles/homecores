# BAREMETAL / VAGRANT
# ===================
# server name : use something like :
#  - vagrant: username-vm-coreos
#  - vagrant: username-bm-coreos
coreos_hostname="forget-hostname-coreos"

# cluster
# ask to your team for the atlas token or follow tutrial in the README file
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

# shell to install (bash or zsh)
shell_to_install="zsh"

# to simplify compatibility cygwin/windows
current_project_folder="c:/Users/username/repository/homecores"

# This parameter will define vagrant public network
# To find on your computer :
# - open a shell
# - go to the VirtualBox folder => (C:\Program Files\Oracle\VirtualBox)
# - run :
#    VBoxManage.exe list bridgedifs # for windows user
# - copy/paste the Name result
public_network_to_use="Qualcomm Atheros AR8151 PCI-E Gigabit Ethernet Controller (NDIS 6.20)"

# turn this on to forget clustering (no connection running)
# need to have one start with this parameter to true
local_test_cluster="false"




# DEPRECATED
# ==========
discovery_token=''

# kubernetes
image_kubernetes='gcr.io/google_containers/hyperkube:v1.0.1'
