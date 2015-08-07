#! /bin/bash

. ./config.sh

# only work with baremetal
./generate.sh
coreos-cloudinit -validate=true --from-file $cloud_config_file && sudo cp $cloud_config_file $user_data_file && sudo reboot
