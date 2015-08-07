#! /bin/bash

coreos-cloudinit -validate=true --from-file ./cloud-config.yml && sudo cp ~/cloud-config/cloud-config.yml /var/lib/coreos-install/user_data && sudo reboot
