# homecores

[![Build Status](https://travis-ci.org/tdeheurles/homecores.svg?branch=master)](https://travis-ci.org/tdeheurles/homecores)

### links
- Vagrant [documentation](https://docs.vagrantup.com/v2/)
- CoreOS [mainpage](https://coreos.com/)
- Consul [main](https://www.consul.io/) and [documentation](https://www.consul.io/docs/index.html)

### TODO
- write tutorial in README.md
- cluster bootstrap alone
- test zsh/oh-my-zsh shell auto installation
   - warning: `env: zsh: No such file or directory`
- add ssh key and passsword
- add 
- local run (no connection) :
   - enable kubelet
- binaries :   
   - At the first run, get all binaries and put them in the binaries folder
     - the idea is someone can pull the repo then launch a prepare and then can be ok for taking a flight
     - kubernetes
     - jq
     - consul
     - coreos box

### Config
- copy `sample.coreos_config.sh` to `config.sh`

### Vagrant
install :
- [VirtualBox](https://www.virtualbox.org/)
- [Vagrant](https://www.vagrantup.com/)

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


### Atlas Token
This atlas token is used by consul to join the cluster.  
If the team have no one :
- go to `https://atlas.hashicorp.com/`
- create an account
- go to the main page `https://atlas.hashicorp.com/` and click on yout username
- enter password
- go to `tokens`
- give a name to have a reminder and click on generate
- copy paste your fresh token

### Issues
TODO