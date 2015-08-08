# security
password=''
id_rsa=''

# cluster
discovery_token=''

# server
hostname=''

# kubernetes
image_kubernetes='gcr.io/google_containers/hyperkube:v1.0.2'



# ===================== ALL IS USER CONFIGURATE AT THIS POINT =======================
# ===================================================================================

templates="`pwd`/templates"
main_folder="`pwd`"

cloud_config_template_file="$templates/template.cloud-config.yml"
cloud_config_file="$main_folder/cloud-config.yml"

user_data_file="/var/lib/coreos-install/user_data"
