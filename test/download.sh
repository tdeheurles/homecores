#! /bin/bash

mkdir -p ./test/downloads

# =========== VIRTUALBOX =========== 
# ==================================
vbox_file=virtualbox-5.0_5.0.2-102096~Ubuntu~trusty_amd64.deb
vbox_path=./test/downloads/virtualbox.deb
if [[ ! -e $vbox_path ]]; then
	curl -L http://download.virtualbox.org/virtualbox/5.0.2/$vbox_file -O
	mv $vbox_file $vbox_path
fi


# =========== VAGRANT ============
# ================================
vagrant_file=vagrant_1.7.4_x86_64.deb
vagrant_path=./test/downloads/vagrant.deb
if [[ ! -e $vagrant_file ]]; then
	curl -L https://dl.bintray.com/mitchellh/vagrant/$vagrant_file -O
	mv $vagrant_file $vagrant_path
fi
