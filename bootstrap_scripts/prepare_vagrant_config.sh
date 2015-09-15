#!/bin/bash

. ./config.sh

cat <<EOF > auto_generated/vagrant_config.rb
\$vm_memory             = $vm_memory
\$vm_cpus               = $vm_cpus
\$core_hostname         = "$coreos_hostname"
\$shell_to_install      = "$shell_to_install"
\$public_network_to_use = "$public_network_to_use"

# Certificates
\$CA_PEM_NAME            = "$CA_PEM_NAME"
\$APISERVER_PEM_NAME     = "$APISERVER_PEM_NAME"
\$APISERVER_KEY_PEM_NAME = "$APISERVER_KEY_PEM_NAME"

\$CA_PEM                 = "$CA_PEM"
\$APISERVER_PEM          = "$APISERVER_PEM"
\$APISERVER_KEY_PEM      = "$APISERVER_KEY_PEM"

\$KUBERNETES_SSL_PATH    = "$KUBERNETES_SSL_PATH"

EOF
