# homecores

[![Build Status](https://travis-ci.org/tdeheurles/homecores.svg?branch=master)](https://travis-ci.org/tdeheurles/homecores)

### links
- Vagrant [documentation](https://docs.vagrantup.com/v2/)
- CoreOS [mainpage](https://coreos.com/)

### Context
- the environment used for test are :
  - Windows 7
    - Cygwin or git bash
    - ConEMU(x64) ==> lots of error
  - Windows 10
    - VirtualBox 5.0
    - ConEMU(x64) ==> lots of error

### Config
- copy `sample.coreos_config.sh` to `config.sh`
Go to `config.sh` and insert the needed element

Add your ssh_key to the project :
 - name : `id_rsa`
 - run `chmod 400 id_rsa` to restrict your key


### Vagrant
install :
- [VirtualBox](https://www.virtualbox.org/)
- [Vagrant](https://www.vagrantup.com/)
- [Cygwin](https://cygwin.com/install.html) as the `GitBash` uses the cmd.exe. ConEMU is not fully functionnal for ssh commands (less does not appear well for example). You can follow the cygwin part of [that guide](http://tdeheurles.github.io/How-to-install-docker-on-windows/#install-cygwin)

### run
`./start.sh`

Some download will then occure

### test and understand
After the script has run, you have been `ssh` to `CoreOS`.  

##### launching
When you have ssh in, you will have to wait for some download and process to be done.  
You can monitor these process by using the `slj` alias for `systemctl list-jobs` :  

```
core@master1 ~ $ slj
 JOB  UNIT                   TYPE    STATE
2265 flanneld.service        start   running
2352 kubelet.service         start   waiting
1315 user-cloudinit@var...   start   running
```

flanneld and kubelet need need to be downloaded. The last is the cloud-config that contains flanneld et kubelet jobs. We also can see that kubelet state is `waiting`. It waits flanneld to be started.

You can also use `sst` (alias for `systemctl status`).

```
 $ sst
● coreos1 RETURN)
    State: running
     Jobs: 5 queued     <==== wait for this to become 0
   Failed: 0 units      <==== must be 0
```

So first, wait for these queued jobs to end. (command does not update, re launch command ;-))

##### test ETCD2
`etcd2` is our distributed KV store. Everything repose on his shoulders.  
The command `elsa` as `etcdctl ls --recursive` should print the value stored on the cluster. Something like that must appear :  
```
username@hostname ~ $ elsa
/coreos.com
/coreos.com/updateengine
/coreos.com/updateengine/rebootlock
/coreos.com/updateengine/rebootlock/semaphore
/coreos.com/network
/coreos.com/network/subnets
/coreos.com/network/subnets/10.200.24.0-24
/coreos.com/network/config
```

##### test FLANNEL
flannel is the technology that create a virtual network for our docker daemons on each host.

The flannel network is defined in the config.sh file :  
For example : `flannel_network="10.200.0.0/16"`.

first look at the flannel environment with the alias `fenv` as `flannel environment`:  
```
$ fenv
FLANNEL_NETWORK=10.200.0.0/16
FLANNEL_SUBNET=10.200.53.1/24
FLANNEL_MTU=1472
FLANNEL_IPMASQ=true
FLANNELD_IFACE=192.168.1.5
```

If the first 4 lines does not appear, flannel container should be downloading.  
If the FLANNELD_IFACE=192.168.1.5 does not appear, there should be a problem with the configuration and the flannel will be local to that computer.

Then, run an `ifconfig` to see the networks.

```
core@coreos1 ~ $ ifconfig                                          
docker0: flags=4099<UP,BROADCAST,MULTICAST>  mtu 1500              
        inet 10.200.24.1  netmask 255.255.255.0  broadcast 0.0.0.0 
        [...]
                                                                   
eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500         
        inet 10.0.2.15  netmask 255.255.255.0  broadcast 10.0.2.255
        [...]
                                                                   
eth1: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500         
        inet 172.16.1.100  netmask 255.255.255.0  broadcast 172.16.
        [...]
                                                                   
eth2: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500         
        inet 192.168.1.39  netmask 255.255.255.0  broadcast 192.168
        [...]
                                                                   
flannel0: flags=4305<UP,POINTOPOINT,RUNNING,NOARP,MULTICAST>  mtu 1
        inet 10.200.24.0  netmask 255.255.0.0  destination 10.200.2
        [...]
                                                                   
lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536                       
        inet 127.0.0.1  netmask 255.0.0.0                          
        [...]
```

We have :
 - docker0 : The inet `must` be the same as the flannel defined in the config. If docker0 does not appear, just run `dbox` command (docker run -ti busybox sh). It will download a small container. Inside container, run `ifconfig`, the eth0 should be something like `10.200.24.4` (corresponding to the flannel CIDR and your flannel0 network).
 - eth0 : this is the vagrant NAT
 - eth1 : this is the vagrant `private_ip`, it's used for NFS (folder sharing)
 - eth2 : this one is `important`. It must corresponds to the ip defined in the `config.sh` file (network_mask="192.168.1"). It's your `public_ip`
 - `flannel0` : This is the one we are looking for. It must be in the CIDR define in `config.sh` (flannel_network="10.200.0.0/16"). It must correpond to :
   - `docker0`
   - `eth0` inside containers.
 - lo : your machine loopback


##### kubectl
kubectl is the CLI that can be used to communicate with kubernetes.
It's downloaded after the CoreOS is up.
Just run `kubectl`, if the help appear. It's fine

##### kubelet and kubernetes
`sytemd` is in charge to run the `kubelet` (kubernetes part that start and stop containers). So to look if everything is fine, just look to your running containers :

- kst (alias that will prompt some kubernetes informations) :
```
username@hostname ~ $ kst
SERVICES
NAME         LABELS                                    SELECTOR   IP(S)         PORT(S)
kubernetes   component=apiserver,provider=kubernetes   <none>     10.200.20.1   443/TCP

RC
CONTROLLER   CONTAINER(S)   IMAGE(S)   SELECTOR   REPLICAS

PODS
NAME                      READY     STATUS    RESTARTS   AGE
kube-controller-coreos1   4/4       Running   0          7m

ENDPOINTS
NAME         ENDPOINTS
kubernetes   10.0.2.15:6443
```

If you have running pods, it's fine. The kubelet have read a config file and started them.
