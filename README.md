# homecores

### TODO
- change update_user_data to work with vagrant
- write README.md
- Automate synced_folder => homcores needed

### Config
For baremetal or vagrant :
- copy `sample.coreos_config.sh` to `coreos_config.sh`

For vagrant :
- copy `sample.vagrant_config.sh` to `coreos_config.sh`
- copy `sample.vagrant_synced_folders.sh` to `coreos_config.sh`

## Issues

0. There is a network issue appearing sometime. If the result of `ifconfig` inside coreos does not give the local network in ipv4:  
   
   - Go to vagarnt network section (~l-125/140) and uncomment these lines :  
       - #ip_public = "192.168.1.0"
       - #config.vm.network :public_network, ip: ip_public, mask: "255.255.255.0"
   - run `vagrant up`
   - run `ifconfig` inside coreos and look for the local network
   - run `vagrant destroy`
   - re-comment the same lines
   - run `vagrant up`
   - It seems to add unknown parameters to virtualbox