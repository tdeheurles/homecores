#!/bin/bash

. ./config.sh

is_master=false
if [[ $master_hostname == "" ]]; then
	is_master=true
fi

cat <<EOF > auto_generated/vagrant_config.rb
\$vm_memory             = $vm_memory
\$vm_cpus               = $vm_cpus
\$core_hostname         = "$coreos_hostname"
\$shell_to_install      = "$shell_to_install"
\$public_network_to_use = "$public_network_to_use"

\$is_master             = $is_master

# Certificates
\$CA_PEM                 = "$CA_PEM"
\$CA_PEM_NAME            = "$CA_PEM_NAME"

\$APISERVER_PEM          = "$APISERVER_PEM"
\$APISERVER_PEM_NAME     = "$APISERVER_PEM_NAME"
\$APISERVER_KEY_PEM      = "$APISERVER_KEY_PEM"
\$APISERVER_KEY_PEM_NAME = "$APISERVER_KEY_PEM_NAME"

\$WORKER_PEM             = "$WORKER_PEM"
\$WORKER_KEY_PEM         = "$WORKER_KEY_PEM"
\$WORKER_PEM_NAME        = "$WORKER_PEM_NAME"
\$WORKER_KEY_PEM_NAME    = "$WORKER_KEY_PEM_NAME"

\$ADMIN_PEM             = "$ADMIN_PEM"
\$ADMIN_KEY_PEM         = "$ADMIN_KEY_PEM"
\$ADMIN_PEM_NAME        = "$ADMIN_PEM_NAME"
\$ADMIN_KEY_PEM_NAME    = "$ADMIN_KEY_PEM_NAME"

\$KUBERNETES_SSL_PATH    = "$KUBERNETES_SSL_PATH"
EOF
