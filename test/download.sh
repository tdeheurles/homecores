#! /bin/bash

# =========== VIRTUALBOX =========== 
# ==================================
vbox_file=./test/downloads/virtualbox.deb
if [[ ! -e $vbox_file ]]; then
	curl -L http://download.virtualbox.org/virtualbox/5.0.2/virtualbox-5.0_5.0.2-102096~Ubuntu~trusty_amd64.deb \
	     -O $vbox_file
fi


# =========== VAGRANT ============
# ================================
vagrant_file=./test/downloads/vagrant.deb
if [[ ! -e $vagrant_file ]]; then
	curl -L https://dl.bintray.com/mitchellh/vagrant/vagrant_1.7.4_x86_64.deb \
	     -O $vagrant_file
fi
