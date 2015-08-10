#! /bin/bash

. ./config.sh

# only work with baremetal
./generate.sh

echo "CoreOS : $hostname will restart, wait a little time for restart"
coreos-cloudinit -validate=true --from-file $cloud_config_file && sudo cp $cloud_config_file $user_data_file && sudo reboot
