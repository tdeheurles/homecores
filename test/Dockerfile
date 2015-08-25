FROM      ubuntu:15.04

RUN       apt-get update

# ================== INSTALL VIRTUALBOX ==================
# ========================================================
RUN       apt-get install git -y



# ================== INSTALL VIRTUALBOX ==================
# ========================================================
RUN       apt-get install dkms -y
RUN       echo y | apt-get install linux-image-3.19.0-26-generic -y
RUN       apt-get install -y libssl1.0.0
RUN       apt-get install -y libvpx1
RUN       apt-get install -y libsdl1.2debian
RUN       apt-get install -y libqtgui4
RUN       apt-get install -y libqtcore4
RUN       apt-get install -y libqt4-opengl
RUN       apt-get install -y libqt4-network
RUN       apt-get install -y libpython2.7
RUN       apt-get install -y libgl1
RUN       apt-get install -y libgl1-mesa-glx
RUN       apt-get install -y libcurl3
RUN       apt-get install -y libxcursor1
RUN       apt-get install -y libxinerama1
RUN       apt-get install -y libxmu6
RUN       apt-get install -y psmisc

COPY      ./test/downloads/virtualbox.deb    /downloads/virtualbox.deb
RUN       dpkg -i /downloads/virtualbox.deb
RUN       /etc/init.d/vboxdrv setup



# =============== INSTALL VAGRANT ===============
# ===============================================
COPY      ./test/downloads/vagrant.deb    /downloads/vagrant.deb
RUN       dpkg -i /downloads/vagrant.deb                         

