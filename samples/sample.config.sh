# Size of the CoreOS cluster created by Vagrant
vm_memory=5000
vm_cpus=1

# server name : use something like :
#  - vagrant: username-vm-coreos
#  - vagrant: username-bm-coreos
coreos_hostname="forget-hostname-core"

# shell to install (bsh or zsh)
shell_to_install="bash"

# security
password=''
id_rsa=''

# cluster
discovery_token=''

# kubernetes
image_kubernetes='gcr.io/google_containers/hyperkube:v1.0.1'

# The mask of the local network used
network_mask="192.168.1"

# Uncomment one of the following
#   BareMetal :
#user_data_file="/var/lib/coreos-install/user_data"
#   Vagrant :
user_data_file="/var/lib/coreos-vagrant/vagrantfile-user-data"

# to simplify compatibility cygwin/windows
current_project_folder="c:/Users/username/repository/homecores"