#! /bin/bash


# ========= PREPARE CONFIG
# ============================================
cat <<EOF > config.sh
coreos_hostname='forget-hostname-coreos'
atlas_token='bavwV4GEDu6p5g.atlasv1.1QRU55g28l1A0OhTT8S3VMYfS9kIDLUlEt7QK0WbqDaRxyAR7vjWQoYu5yRNXKHiao0'
password=''
id_rsa=''
user_data_file='/var/lib/coreos-vagrant/vagrantfile-user-data'
network_mask='192.168.1'
vm_memory=2000
vm_cpus=1
shell_to_install='bash'
current_project_folder='/repository/homecores'
public_network_to_use='eth0'
local_test_cluster='false'
discovery_token=''
image_kubernetes='gcr.io/google_containers/hyperkube:v1.0.1'
EOF


# ========= RUN HOMECORES
# ============================================
chmod 755 ./bootstrap_vagrant.sh
./bootstrap_vagrant.sh


# ========= TEST HOMECORES is STARTED
# ============================================
vagrant ssh -c "echo hello-world"
