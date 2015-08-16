# homecores

### TODO
- write tutorial in README.md
- bootstrap alone
- test zsh/oh-my-zsh shell auto installation

### Config
- copy `sample.coreos_config.sh` to `config.sh`

### Vagrant
run :
```bash
./bootstrap_vagrant.sh
```

## baremetal
Start by copying `samples/sample.coreos_config.sh` to `config.sh` and update it :  
```
cp samples/sample.coreos_config.sh config.sh
vi config.sh
```

Finally run the update script to generate and config the cloud-config :  
```
./run_vagrant.sh
```


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
