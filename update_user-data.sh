#! /bin/bash

./generate.sh
coreos-cloudinit -validate=true --from-file ./cloud-config.yml && sudo cp ./cloud-config.yml /var/lib/coreos-install/user_data && sudo reboot
