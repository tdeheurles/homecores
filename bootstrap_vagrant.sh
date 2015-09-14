#! /bin/bash

# control usage
if [[ ! -f config.sh ]]; then
	echo "you need to prepare the config.sh file first"
	echo "open config.sh"
	cp templates/templates.config.sh config.sh
	exit 1
fi

echo "Prepare folders"
mkdir -p auto_generated
rm -rf auto_generated/*

echo "Prepare config for different services"
./bootstrap_scripts/prepare_config_files.sh

echo "Launch Vagrant"
vagrant global-status --prune
vagrant destroy -f && vagrant up && vagrant ssh
