#!/bin/bash

. ./config.sh

cat <<EOF > auto_generated/vagrant_config.rb
\$vm_memory             = $vm_memory
\$vm_cpus               = $vm_cpus
\$core_hostname         = "$coreos_hostname"
\$shell_to_install      = "$shell_to_install"
\$public_network_to_use = "$public_network_to_use"
EOF
