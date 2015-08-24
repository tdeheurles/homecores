FROM    ubuntu:15.04

RUN     sudo apt-get update                                                        \
     && sudo apt-get install git -y                                                \
     && echo "deb http://download.virtualbox.org/virtualbox/debian trusty contrib" \
     && | sudo tee -a /etc/apt/sources.list > /dev/null                            \
     && wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O-            \
     && | sudo apt-key add -                                                       \
     && sudo apt-get update                                                        \
     && sudo apt-get install linux-headers-3.13.0-35-generic -y                    \
     && sudo apt-get install virtualbox-4.3 -y                                     \
     && sudo /etc/init.d/vboxdrv setup                                             \
     && wget https://dl.bintray.com/mitchellh/vagrant/vagrant_1.7.4_x86_64.deb     \
     && sudo dpkg --install vagrant_1.7.4_x86_64.deb                               \
