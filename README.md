# homecores

## Introduction

### What is homecores

`homecores` is a project to run a `kubernetes cluster` on `VirtualMachines`.  Each virtual machine starts on a different computer, so you can easily work with your pods before moving them to production.  
It's for development.  


### What is not homecores

It's not intended to replace a real high availability cluster.  
The idea is not to have a production grade cluster with that product.

### Context

- the environments used for testing are:
  - Windows 7/10
  - VirtualBox 5.0
  - Cygwin or git bash

### What this project needs

The project is a `ruby script`, that run a `virtualbox image` with the help of `vagrant`.

So you will need:

- Virtualbox
- Vagrant
- an ssh client

A word on certificates:  
- To simplify the first run, demo certificates are given for the kubernetes cluster and the user. You will find a guide [here](/docs/certificates.md) on how to generate your own.

## Prerequisite

### Virtualbox

[Download](https://www.virtualbox.org/wiki/Downloads) and install VirtualBox  

### Vagrant

[Download](https://www.vagrantup.com/downloads.html) and install Vagrant  

### ssh client

There are lots of ssh clients. For windows, you can use the one that come with that [git installer](https://git-scm.com/).    
Windows CMD is limitative, you should look for [babun](http://babun.github.io/).

## Preparing the project

### Configuration, Step by Step

- Start a terminal and move to the folder where you want to clone the project
- run `git clone https://github.com/tdeheurles/homecores`
- go in the project with `cd homecores`
- run `./start.sh`. This will generate the file `config.sh`
- Edit `config.sh` with a text editor of your choice

You should have this:

```bash
# =================== USER CONFIGURATION ====================
# ===========================================================

# server name :
#  - this just need to be different for every virtual machine
coreos_hostname="master1"

# The mask of the local network used
network_mask="192.168.1"

# the network interface to use for virtualbox
#   refer to the README.md for information on how to get it
public_network_to_use="Qualcomm Atheros AR8151 PCI-E Gigabit Ethernet Controller (NDIS 6.20)"



# ========================== OPTIONAL =======================
# ===========================================================
[...]
```

- You can let `coreos_hostname=master1`, it just needs to be unique on the cluster.
- Enter the mask of your local network. This one is used to `grep` the ip_address after the start of CoreOS.
- The third information is a bit more difficult to found. It's a vagrant configuration that can be found with a virtualbox tool:
  - run a new CLI (GitBash or another)
  - go to the virtualbox installation
    - for windows it's `cd "C:\Program Files\Oracle\VirtualBox"`
  - run `vboxmanage list bridgedifs`
  - the information needed is the one corresponding to `Name:`
  - So as an example:

```bash
➜  cd "C:\Program Files\Oracle\VirtualBox"
➜  vboxmanage list bridgedifs
Name:            Qualcomm Atheros AR8151 PCI-E Gigabit Ethernet Controller (NDIS 6.20)
GUID:            f99dc65b-6c35-4790-bc6b-3d36d2638c8b
DHCP:            Enabled
IPAddress:       192.168.1.28
NetworkMask:     255.255.255.0
IPV6Address:     fe80:0000:0000:0000:052f:51af:4d49:9ccc
IPV6NetworkMaskPrefixLength: 64
HardwareAddress: 90:2b:34:58:5f:71
MediumType:      Ethernet
Status:          Up
VBoxNetworkName: HostInterfaceNetworking-Qualcomm Atheros AR8151 PCI-E Gigabit Ethernet Controller (NDIS 6.20)
```

Here, I will write `public_network_to_use="Qualcomm Atheros AR8151 PCI-E Gigabit Ethernet Controller (NDIS 6.20)"` in my config.sh file.

## Running the project

Open a `terminal` and run `./start.sh`.  
Some download will occure.  
Then run into VM with `vagrant ssh -- -i ./id_rsa`

Here is an example of the `./start.sh` script:

```bash
➜  ./start.sh
==> master1: VM not created. Moving on...
Bringing machine 'master1' up with 'virtualbox' provider...
==> master1: Box 'coreos-alpha' could not be found. Attempting to find and install...
    master1: Box Provider: virtualbox
    master1: Box Version: >= 0
==> master1: Loading metadata for box 'http://alpha.release.core-os.net/amd64-usr/current/coreos_production_vagrant.json'
    master1: URL: http://alpha.release.core-os.net/amd64-usr/current/coreos_production_vagrant.json
==> master1: Adding box 'coreos-alpha' (v801.0.0) for provider: virtualbox
    master1: Downloading: http://alpha.release.core-os.net/amd64-usr/801.0.0/coreos_production_vagrant.box
    master1:
    master1: Calculating and comparing box checksum...
==> master1: Successfully added box 'coreos-alpha' (v801.0.0) for 'virtualbox'!
==> master1: Importing base box 'coreos-alpha'...
==> master1: Matching MAC address for NAT networking...
==> master1: Checking if box 'coreos-alpha' is up to date...
==> master1: Setting the name of the VM: homecores_master1_1442503740277_51132
==> master1: Clearing any previously set network interfaces...
==> master1: Preparing network interfaces based on configuration...
    master1: Adapter 1: nat
    master1: Adapter 2: bridged
    master1: Adapter 3: hostonly
==> master1: Forwarding ports...
    master1: 22 => 2222 (adapter 1)
==> master1: Running 'pre-boot' VM customizations...
==> master1: Booting VM...
==> master1: Waiting for machine to boot. This may take a few minutes...
    master1: SSH address: 127.0.0.1:2222
    master1: SSH username: core
    master1: SSH auth method: private key
    master1: Warning: Remote connection disconnect. Retrying...
==> master1: Machine booted and ready!
==> master1: Setting hostname...
==> master1: Configuring and enabling network interfaces...
==> master1: Running provisioner: shell...
    master1: Running: inline script
==> master1: Running provisioner: file...
==> master1: Running provisioner: file...
[... some provisioner lines ...]
==> master1: Running provisioner: file...
==> master1: Running provisioner: shell...
    master1: Running: inline script
```

### How to test that everything is started correctly
If the script run successfully, you have been `ssh` to `CoreOS`.  
Downloads will now be running (~250Mb).

#### Short Way:

- run `slj` and wait that the jobs are finished

```bash
core@master1 ~ $ slj
No jobs running.
```

- then run `dps` and wait for 8 containers to show up:

```bash
core@master1 ~ $ dps
CONTAINER ID        IMAGE                                       COMMAND                  CREATED             STATUS              PORTS               NAMES
259d16ba012e        gcr.io/google_containers/hyperkube:v1.0.6   "/hyperkube apiserver"   5 minutes ago       Up 5 minutes                            k8s_kube-apiserver.7bff4b40_kube-apiserver-192.168.1.83_default_7c4bf9aa9cfff4a366b0d917afef89de_95633f59
34e88c61ef41        gcr.io/google_containers/hyperkube:v1.0.6   "/hyperkube scheduler"   5 minutes ago       Up 5 minutes                            k8s_kube-scheduler.96058e0_kube-scheduler-192.168.1.83_default_1ad6d2fbf3f144bb17dc21ee398dd6e1_b4b085f8
ae1d4d3158d2        gcr.io/google_containers/hyperkube:v1.0.6   "/hyperkube proxy --m"   5 minutes ago       Up 5 minutes                            k8s_kube-proxy.db703083_kube-proxy-192.168.1.83_default_8770f171ca1f4f9d4aaf724284527622_badbb059
cd672b7d81fb        gcr.io/google_containers/hyperkube:v1.0.6   "/hyperkube controlle"   5 minutes ago       Up 5 minutes                            k8s_kube-controller-manager.b9acaee_kube-controller-manager-192.168.1.83_default_96779ee4ab5a79bb2f082a7e48fa30be_bd00fa84
5aea94e92c32        gcr.io/google_containers/pause:0.8.0        "/pause"                 7 minutes ago       Up 7 minutes                            k8s_POD.e4cc795_kube-proxy-192.168.1.83_default_8770f171ca1f4f9d4aaf724284527622_ecba1f9b
707eb50ffa21        gcr.io/google_containers/pause:0.8.0        "/pause"                 7 minutes ago       Up 7 minutes                            k8s_POD.e4cc795_kube-scheduler-192.168.1.83_default_1ad6d2fbf3f144bb17dc21ee398dd6e1_028b4c97
ea54b11143fa        gcr.io/google_containers/pause:0.8.0        "/pause"                 7 minutes ago       Up 7 minutes                            k8s_POD.e4cc795_kube-controller-manager-192.168.1.83_default_96779ee4ab5a79bb2f082a7e48fa30be_6f97c15e
b6e5a8db5d9b        gcr.io/google_containers/pause:0.8.0        "/pause"                 7 minutes ago       Up 7 minutes                            k8s_POD.e4cc795_kube-apiserver-192.168.1.83_default_7c4bf9aa9cfff4a366b0d917afef89de_ad4194e4
```

- run `kst` and look for something like that to appear:

```bash
core@master1 ~ $ kst
SERVICES
NAME         LABELS                                    SELECTOR   IP(S)      PORT(S)
kubernetes   component=apiserver,provider=kubernetes   <none>     10.3.0.1   443/TCP

RC
CONTROLLER   CONTAINER(S)   IMAGE(S)   SELECTOR   REPLICAS

PODS
NAME                                   READY     STATUS    RESTARTS   AGE
kube-apiserver-192.168.1.83            1/1       Running   0          1m
kube-controller-manager-192.168.1.83   1/1       Running   0          1m
kube-proxy-192.168.1.83                1/1       Running   0          1m
kube-scheduler-192.168.1.83            1/1       Running   0          1m

ENDPOINTS
NAME         ENDPOINTS
kubernetes   192.168.1.83:443

NODES
NAME           LABELS                                STATUS
192.168.1.83   kubernetes.io/hostname=192.168.1.83   Ready
```

If you see the 4 kube containers running, it's cool!

#### Detailed way

##### Wait for systemd jobs
When you have ssh in, you will have to wait for some download and process to be done.  
You can monitor these processes by using the `slj` alias for `systemctl list-jobs` :  

```bash
core@master1 ~ $ slj
 JOB  UNIT                   TYPE    STATE
2265 flanneld.service        start   running
2352 kubelet.service         start   waiting
1315 user-cloudinit@var...   start   running
```

flanneld and kubelet need to be downloaded.  
The last is the cloud-config that contains flanneld et kubelet jobs.  
We can also see that kubelet state is `waiting`. It waits flanneld to be started.

You can also use `sst` (alias for `systemctl status`).

```bash
 $ sst
● coreos1 RETURN)
    State: running
     Jobs: 5 queued     <==== wait for this to become 0
   Failed: 0 units      <==== must be 0
   [...]
```

So first, wait for these queued jobs to end. (command does not update, re launch command ;-))

##### Control ETCD2 Key/Value store
`etcd2` is our distributed KV store. Everything rests on his shoulders.  
The command `elsa` as `etcdctl ls --recursive` should print the value stored on the cluster. Something like that must appear:  

```bash
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

##### Control the FLANNEL network
flannel is the technology that create a virtual network for our docker daemons on each host.

The flannel network is defined in the config.sh file:  
For example : `flannel_network="10.200.0.0/16"`.

first look at the flannel environment with the alias `fenv` as `flannel environment`:  

```bash
$ fenv
FLANNEL_NETWORK=10.200.0.0/16
FLANNEL_SUBNET=10.200.53.1/24
FLANNEL_MTU=1472
FLANNEL_IPMASQ=true
FLANNELD_IFACE=192.168.1.5
```

If the first 4 lines don't appear, flannel container should be downloading.  
If the FLANNELD_IFACE=192.168.1.5 does not appear, there should be a problem with the configuration and the flannel will be local to that computer.

Then, run an `ifconfig` to see the networks.

```bash
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

We have:
 - docker0: The inet `must` be the same as the flannel defined in the config. If docker0 does not appear, just run `dbox` command (docker run -ti busybox sh). It will download a small container. Inside this container, run `ifconfig`, the eth0 should be something like `10.200.24.4` (corresponding to the flannel CIDR and your flannel0 network).
 - eth0: this is the vagrant NAT
 - eth1: this is the vagrant `private_ip`, it's used for NFS (folder sharing)
 - eth2: this one is `important`. It must corresponds to the ip defined in the `config.sh` file (network_mask="192.168.1"). It's your `public_ip`
 - `flannel0`: This is the one we are looking for. It must be in the CIDR define in `config.sh` (flannel_network="10.200.0.0/16"). It must correpond to:
   - `docker0`
   - `eth0` inside containers.
 - lo: your machine loopback


##### The kubernetes controller: kubectl
kubectl is the CLI that can be used to communicate with kubernetes.
It's downloaded after CoreOS is up.
Just run `kubectl`, if the help appears then it's fine

##### kubelet and kubernetes
`sytemd` is in charge of running the `kubelet` (kubernetes part that starts and stops containers). So to look if everything is fine, just look to your running containers:

- kst (alias that will prompt some kubernetes informations):
```bash
core@master1 ~ $ kst
SERVICES
NAME         LABELS                                    SELECTOR   IP(S)      PORT(S)
kubernetes   component=apiserver,provider=kubernetes   <none>     10.3.0.1   443/TCP

RC
CONTROLLER   CONTAINER(S)   IMAGE(S)   SELECTOR   REPLICAS

PODS
NAME                                   READY     STATUS    RESTARTS   AGE
kube-apiserver-192.168.1.83            1/1       Running   0          1m
kube-controller-manager-192.168.1.83   1/1       Running   0          1m
kube-proxy-192.168.1.83                1/1       Running   0          1m
kube-scheduler-192.168.1.83            1/1       Running   0          1m

ENDPOINTS
NAME         ENDPOINTS
kubernetes   192.168.1.83:443

NODES
NAME           LABELS                                STATUS
192.168.1.83   kubernetes.io/hostname=192.168.1.83   Ready
```

If you have running pods, it's fine. The kubelet have read a config file and started them.
