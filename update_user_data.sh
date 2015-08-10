#! /bin/bash

. ./config.sh

./generate.sh

echo " "
echo -e "\e[94mwill restart\e[39m"
echo -e "\e[94mtry to connect in a minute with :\e[39m"
echo " "
echo -e "        \e[92mssh core@$public_ip\e[39m"
echo " "
coreos-cloudinit -validate=true --from-file $cloud_config_file && sudo cp $cloud_config_file $user_data_file && sudo reboot
