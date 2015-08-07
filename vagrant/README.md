# CoreOS Vagrant

## How to

### Go into the Core
- Copy `template/user-data.sample`, `template/config.sample.rb` and `template/synced_folders.sample.yaml` to `user-data`, `config.rb`  and `synced_folders.yaml`
- Go to the fresh `config.rb` and choose your parameters
- Run a terminal and go to project folder
- `vagrant up`
- then ssh in :

  You can `vagrant ssh`

  Or use **Putty**. For putty you will have to [download/install](http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html) `PuTTY and PuTTYgen` (download the win installer). Then generate a putty key from the vagrant key `C:\Users\username\.vagrant.d\insecure_private_key` with PuTTYgen (Load -> Path -> Save).

  Launch `PuTTY`. Go to `Connection->SSH->Auth` browse to add your key (the .ppk one), then go to Session and give Host Name core@127.0.0.1. Add a name in Saved Sessions and save it.

  Launch your session and add a shortcut with `rightClick on windows running icon -> Pin`.

  Now all your new Vagrant should be easily joined


- If you want to use docker from windows, you will need to `set DOCKER_HOST=tcp://127.0.0.1:2375` in cmd.exe (maybe a [boot2docker](http://boot2docker.io/) installation is needed. Look the [docker helper](https://github.com/tdeheurles/docs/tree/master/docker))
- I started some documentation [here](https://github.com/tdeheurles/docs/tree/master/cygwin) to use cygwin instead of cmd.exe

### Config gcloud && kubectl
Check :
- You are now inside you're CoreOs. You are the user `core`.
- Control that docker is ok with a `docker ps`

Now we will get in gcloud using the [gcloud-tools](https://github.com/tdeheurles/gcloud-tools) container. I added some functions and alias (shortcuts) to simplify the usage.

Here are some :

```
---------  ---------------------  --------------------  ------------------------------------
command    meaning                args                  function
---------  ---------------------  --------------------  ------------------------------------
                             AUTHENTICATION ETC
glogin     google login           None                  will do the authentication process.
                                                           You will need a browser and two
                                                           copy/paste. This is done only one
                                                           time

gsp        set project            project name          You need to do this each time you
                                                           switch gcloud project

ggc        get credentials        cluster name          This will get credentials for the
                                                           cluster

                       -----------------------------------
                                     STATUS
kcv        k8s config view        None                  Give the list of available cluster
                                                           (with credentials already taken)

gfor       forwarding-rules       None                  Get the forwarding-rules

gfir       firewall-rules         None                  Get firewall-rules

kst        k8s status             opt: namespace name   Give service/rc/pods from a namespace
                                                           (default if no argument)

                       -----------------------------------
                                     WORK ON
kscale     kubectl scale          rc name               Change the number of running pods
                                  scale quantity           for a replication controller


                       -----------------------------------
                                     DOCKER
dps        docekr ps              None                  see docker running containers

dpsa       docekr ps -A           None                  see docker running and runned
                                                            containers

dim        docker images          None                  See docker images

---------  ---------------------  --------------------  ------------------------------------
```

1. So first log using `glogin`. It will give you an URL that you will copy/paste to your browser, and get back the token.
2. Then set the project to use : `gsp epsilon-cloud-rnd jenkins`
3. Get the credentials for a cluster in the project `ggc cloud-rnd`
4. Finally we will control that everything is ok by getting some status information : `kst`


## From Original Fork (not updated with this changes)

This repo provides a template Vagrantfile to create a CoreOS virtual machine using the VirtualBox software hypervisor.
After setup is complete you will have a single CoreOS virtual machine running on your local machine.

## Streamlined setup

1) Install dependencies

* [VirtualBox][virtualbox] 4.3.10 or greater.
* [Vagrant][vagrant] 1.6 or greater.

2) Clone this project and get it running!

```
git clone https://github.com/coreos/coreos-vagrant/
cd coreos-vagrant
```

3) Startup and SSH

There are two "providers" for Vagrant with slightly different instructions.
Follow one of the following two options:

**VirtualBox Provider**

The VirtualBox provider is the default Vagrant provider. Use this if you are unsure.

```
vagrant up
vagrant ssh
```

**VMware Provider**

The VMware provider is a commercial addon from Hashicorp that offers better stability and speed.
If you use this provider follow these instructions.

VMware Fusion:
```
vagrant up --provider vmware_fusion
vagrant ssh
```

VMware Workstation:
```
vagrant up --provider vmware_workstation
vagrant ssh
```

``vagrant up`` triggers vagrant to download the CoreOS image (if necessary) and (re)launch the instance

``vagrant ssh`` connects you to the virtual machine.
Configuration is stored in the directory so you can always return to this machine by executing vagrant ssh from the directory where the Vagrantfile was located.

4) Get started [using CoreOS][using-coreos]

[virtualbox]: https://www.virtualbox.org/
[vagrant]: https://www.vagrantup.com/downloads.html
[using-coreos]: http://coreos.com/docs/using-coreos/

#### Shared Folder Setup

There is optional shared folder setup.
You can try it out by adding a section to your Vagrantfile like this.

```
config.vm.network "private_network", ip: "172.17.8.150"
config.vm.synced_folder ".", "/home/core/share", id: "core", :nfs => true,  :mount_options   => ['nolock,vers=3,udp']
```

After a 'vagrant reload' you will be prompted for your local machine password.

#### Provisioning with user-data

The Vagrantfile will provision your CoreOS VM(s) with [coreos-cloudinit][coreos-cloudinit] if a `user-data` file is found in the project directory.
coreos-cloudinit simplifies the provisioning process through the use of a script or cloud-config document.

To get started, copy `user-data.sample` to `user-data` and make any necessary modifications.
Check out the [coreos-cloudinit documentation][coreos-cloudinit] to learn about the available features.

[coreos-cloudinit]: https://github.com/coreos/coreos-cloudinit

#### Configuration

The Vagrantfile will parse a `config.rb` file containing a set of options used to configure your CoreOS cluster.
See `config.rb.sample` for more information.

## Cluster Setup

Launching a CoreOS cluster on Vagrant is as simple as configuring `$num_instances` in a `config.rb` file to 3 (or more!) and running `vagrant up`.
Make sure you provide a fresh discovery URL in your `user-data` if you wish to bootstrap etcd in your cluster.

## New Box Versions

CoreOS is a rolling release distribution and versions that are out of date will automatically update.
If you want to start from the most up to date version you will need to make sure that you have the latest box file of CoreOS.
Simply remove the old box file and vagrant will download the latest one the next time you `vagrant up`.

```
vagrant box remove coreos --provider vmware_fusion
vagrant box remove coreos --provider vmware_workstation
vagrant box remove coreos --provider virtualbox
```

## Docker Forwarding

By setting the `$expose_docker_tcp` configuration value you can forward a local TCP port to docker on
each CoreOS machine that you launch. The first machine will be available on the port that you specify
and each additional machine will increment the port by 1.

Follow the [Enable Remote API instructions][coreos-enabling-port-forwarding] to get the CoreOS VM setup to work with port forwarding.

[coreos-enabling-port-forwarding]: https://coreos.com/docs/launching-containers/building/customizing-docker/#enable-the-remote-api-on-a-new-socket

Then you can then use the `docker` command from your local shell by setting `DOCKER_HOST`:

    export DOCKER_HOST=tcp://localhost:2375
