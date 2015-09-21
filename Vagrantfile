# -*- mode: ruby -*-
# # vi: set ft=ruby :

require 'fileutils'

Vagrant.require_version ">= 1.6.0"

CONFIG = File.join(File.dirname(__FILE__), "auto_generated/vagrant_config.rb")
MOUNT_POINTS = YAML::load_file('synced_folders.yml')

# Defaults for config options defined in CONFIG
$core_hostname = ""
$num_instances = 1
$update_channel = "alpha"
$image_version =  "801.0" #"current"
$enable_serial_logging = false
$share_home = false
$vm_gui = false
$vm_memory = 6000
$vm_cpus = 1
$linux_shared_folders = {}
$windows_shared_folders = {}
$forwarded_ports = {}

module OS
  def OS.windows?
    (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
  end

  def OS.mac?
   (/darwin/ =~ RUBY_PLATFORM) != nil
  end

  def OS.unix?
    !OS.windows?
  end

  def OS.linux?
    OS.unix? and not OS.mac?
  end
end


required_plugins = %w(vagrant-triggers vagrant-reload)

# check either 'http_proxy' or 'HTTP_PROXY' environment variable
if OS.windows?
  required_plugins.push('vagrant-winnfsd')
end

required_plugins.each do |plugin|
  need_restart = false
  unless Vagrant.has_plugin? plugin
    system "vagrant plugin install #{plugin}"
    need_restart = true
  end
  exec "vagrant #{ARGV.join(' ')}" if need_restart
end

# import ruby config
if File.exist?(CONFIG)
  require CONFIG
end

# # Use old vb_xxx config variables when set
def vm_gui
  $vb_gui.nil? ? $vm_gui : $vb_gui
end

def vm_memory
  $vb_memory.nil? ? $vm_memory : $vb_memory
end

def vm_cpus
  $vb_cpus.nil? ? $vm_cpus : $vb_cpus
end

Vagrant.configure("2") do |config|
  # always use Vagrants insecure key
  config.ssh.insert_key       = false

  # =============== IMAGE
  # =============================================
  config.vm.box = "coreos-%s" % $update_channel
  if $image_version != "current"
      config.vm.box_version = $image_version
  end

  config.vm.box_url = "http://%s.release.core-os.net/amd64-usr/%s/coreos_production_vagrant.json" % [$update_channel, $image_version]

  config.vm.provider :virtualbox do |v|
    # On VirtualBox, we don't have guest additions or a functional vboxsf
    # in CoreOS, so tell Vagrant that so it can be smarter.
    v.check_guest_additions = false
    v.functional_vboxsf     = false
  end

  # plugin conflict
  if Vagrant.has_plugin?("vagrant-vbguest") then
    config.vbguest.auto_update = false
  end

  config.vm.define vm_name = $core_hostname do |config|
    config.vm.hostname = $core_hostname
    config.vm.provider :virtualbox do |vb|
      vb.gui = vm_gui
      vb.memory = vm_memory
      vb.cpus = vm_cpus
      vb.customize ["modifyvm", :id, "--vram", "24"]
    end

    # =============== NETWORK
    # =============================================
    # Forward docker
    #config.vm.network "forwarded_port", guest: 2375, host: $expose_docker_tcp, auto_correct: true
      
    # Forward for ETCD
    # config.vm.network "forwarded_port", guest: 2379, host: 2379, auto_correct: true
    # config.vm.network "forwarded_port", guest: 2380, host: 2380, auto_correct: true

    # Forward for FLANNEL
    # config.vm.network "forwarded_port", guest: 8285, host: 8285, auto_correct: true, protocol: 'udp'
    # config.vm.network "forwarded_port", guest: 8472, host: 8472, auto_correct: true, protocol: 'udp'

    # forward ports
    $forwarded_ports.each do |guest, host|
      config.vm.network "forwarded_port", guest: guest, host: host, auto_correct: true
    end

    # public network
    #   - network used bt the cluster 
    config.vm.network :public_network,
                      bridge: "#{$public_network_to_use}"

    # private network :
    #   - needed by nfs
    #   - request admin privilege window
    ip_private = "172.16.1.100"
    config.vm.network :private_network, ip: ip_private

    # =============== SHARED FOLDERS
    # =============================================
    begin
      MOUNT_POINTS.each do |mount|
        mount_options = ""
        disabled = false
        nfs =  true
        if mount['mount_options']
          mount_options = mount['mount_options']
        end
        if mount['disabled']
          disabled = mount['disabled']
        end
        if mount['nfs']
          nfs = mount['nfs']
        end
        if File.exist?(File.expand_path("#{mount['source']}"))
          if mount['destination']
            config.vm.synced_folder "#{mount['source']}", "#{mount['destination']}",
              id: "#{mount['name']}",
              disabled: disabled,
              mount_options: ["#{mount_options}"],
              nfs: nfs
          end
        end
      end
    rescue
    end

    # =============== RCFILES
    # =============================================
    # ZSH
    if $shell_to_install == "zsh"
      config.vm.provision :shell, :inline => "rm /home/core/.bashrc"
      
      config.vm.provision :file, :source => "templates/zsh/.bashrc",    :destination => "/home/core/.bashrc"
      config.vm.provision :file, :source => "templates/zsh/.zshrc",     :destination => "/home/core/.zshrc"
      config.vm.provision :file, :source => "templates/zsh/zsh",        :destination => "/home/core/zsh"
      config.vm.provision :file, :source => "templates/zsh/.oh-my-zsh", :destination => "/home/core/.oh-my-zsh"
      
      config.vm.provision :shell, :inline => "chmod 755 /home/core/zsh/bin/zsh"
    end

    # BASH
    if $shell_to_install == "bash"
      config.vm.provision :shell, :inline => "rm /home/core/.bashrc"
      config.vm.provision :file,  :source => "templates/bash/.bashrc",    
                          :destination => "/home/core/.bashrc"
    end

    config.vm.provision :file, :source => "templates/.commonrc",      :destination => "/home/core/.commonrc"


    # ================== KUBERNETES
    # ==============================================
    
    # kubernetes manifests
    # ====================
    config.vm.provision :shell, keep_color: true,
                        :inline => "mkdir -p /etc/kubernetes/manifests"

    if $is_master == true
      # --apiserver
      config.vm.provision :file, :source => "auto_generated/kubernetes/kube-apiserver.yml", 
                          :destination => "/tmp/kube-apiserver.yml"

      config.vm.provision :shell, keep_color: true,
                          :inline => "mv /tmp/kube-apiserver.yml /etc/kubernetes/manifests/kube-apiserver.yml"

      # --controller
      config.vm.provision :file, :source => "auto_generated/kubernetes/kube-controller.yml", 
                          :destination => "/tmp/kube-controller.yml"

      config.vm.provision :shell, keep_color: true,
                          :inline => "mv /tmp/kube-controller.yml /etc/kubernetes/manifests/kube-controller.yml"

      # --scheduler    
      config.vm.provision :file, :source => "auto_generated/kubernetes/kube-scheduler.yml", 
                          :destination => "/tmp/kube-scheduler.yml"

      config.vm.provision :shell, keep_color: true,
                          :inline => "mv /tmp/kube-scheduler.yml /etc/kubernetes/manifests/kube-scheduler.yml"
    else
      # --node_kubeconfig
      config.vm.provision :file, :source => "auto_generated/kubernetes/node_kubeconfig.yml", 
                          :destination => "/tmp/node_kubeconfig.yml"

      config.vm.provision :shell, keep_color: true,
                          :inline => "mv /tmp/node_kubeconfig.yml /etc/kubernetes/node_kubeconfig.yml"
    end
    
    # --proxy
    config.vm.provision :file, :source => "auto_generated/kubernetes/kube-proxy.yml", 
                        :destination => "/tmp/kube-proxy.yml"

    config.vm.provision :shell, keep_color: true,
                        :inline => "mv /tmp/kube-proxy.yml /etc/kubernetes/manifests/kube-proxy.yml"


    # certificates
    # ============
    config.vm.provision :shell, keep_color: true,
                        :inline => "mkdir -p #{$KUBERNETES_SSL_PATH}"

    config.vm.provision :file, :source => "#{$CA_PEM}", 
                        :destination =>   "/tmp/#{$CA_PEM_NAME}"

    if $is_master == true
      # MASTER
      config.vm.provision :file, :source => "#{$APISERVER_PEM}", 
                          :destination =>   "/tmp/#{$APISERVER_PEM_NAME}"

      config.vm.provision :file, :source => "#{$APISERVER_KEY_PEM}", 
                          :destination =>   "/tmp/#{$APISERVER_KEY_PEM_NAME}"

      config.vm.provision :shell, :privileged => true,
          inline: <<-EOF
          mv /tmp/#{$CA_PEM_NAME}            #{$KUBERNETES_SSL_PATH}
          mv /tmp/#{$APISERVER_PEM_NAME}     #{$KUBERNETES_SSL_PATH}
          mv /tmp/#{$APISERVER_KEY_PEM_NAME} #{$KUBERNETES_SSL_PATH}
          EOF
    else
      # NODE
      config.vm.provision :file, :source => "#{$WORKER_PEM}", 
                          :destination =>   "/tmp/#{$WORKER_PEM_NAME}"

      config.vm.provision :file, :source => "#{$WORKER_KEY_PEM}", 
                          :destination =>   "/tmp/#{$WORKER_KEY_PEM_NAME}"

      config.vm.provision :file, :source => "#{$ADMIN_PEM}", 
                          :destination =>   "/tmp/#{$ADMIN_PEM_NAME}"

      config.vm.provision :file, :source => "#{$ADMIN_KEY_PEM}", 
                          :destination =>   "/tmp/#{$ADMIN_KEY_PEM_NAME}"

      config.vm.provision :shell, :privileged => true,
          inline: <<-EOF
          mv /tmp/#{$CA_PEM_NAME}         #{$KUBERNETES_SSL_PATH}
          mv /tmp/#{$WORKER_PEM_NAME}     #{$KUBERNETES_SSL_PATH}
          mv /tmp/#{$WORKER_KEY_PEM_NAME} #{$KUBERNETES_SSL_PATH}
          mv /tmp/#{$ADMIN_PEM_NAME}      #{$KUBERNETES_SSL_PATH}
          mv /tmp/#{$ADMIN_KEY_PEM_NAME}  #{$KUBERNETES_SSL_PATH}
          EOF
    end


    # ================== CLOUD-CONFIG
    # ==============================================
    config.vm.provision :file, :source => "auto_generated/cloud_config.yml", :destination => "/tmp/vagrantfile-user-data"
    config.vm.provision :shell, :inline => "mv /tmp/vagrantfile-user-data /var/lib/coreos-vagrant/"
  end
end
