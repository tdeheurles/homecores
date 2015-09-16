#!/bin/bash


homecoresdirectory="/cygdrive/c/Users/..."
newdirectory="/cygdrive/c/Users/..."



copy() {
	rm -rf $newdirectory/$1
	cp -rf $homecoresdirectory/$1 \
           $newdirectory/$1
}

copy bootstrap_scripts
copy certificates
copy templates
copy .gitattributes
copy .gitignore
copy id_rsa
copy README.md
copy ssh_coreos.sh
copy start.sh
copy Vagrantfile

./start.sh
