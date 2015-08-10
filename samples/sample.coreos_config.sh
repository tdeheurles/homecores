# security
password=''
id_rsa=''

# cluster
discovery_token=''

# server name : use something like :
#  - vagrant: username-vm-coreos
#  - vagrant: username-bm-coreos
coreos_hostname="username-_m-coreos"

# kubernetes
image_kubernetes='gcr.io/google_containers/hyperkube:v1.0.1'

# The mask of the network used
network_mask="192.168.1"

# Uncomment one of the following
#   BareMetal :
#user_data_file="/var/lib/coreos-install/user_data"
#   Vagrant :
user_data_file="/var/lib/coreos-vagrant/vagrantfile-user-data"


# ===================== ALL IS USER CONFIGURATE AT THIS POINT =======================
# ===================================================================================

templates="`pwd`/templates"
main_folder="`pwd`"

cloud_config_template_file="$templates/template.cloud-config.yml"
cloud_config_file="$main_folder/cloud-config.yml"
