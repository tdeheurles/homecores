# -*- mode: ruby -*-
# vi: set ft=ruby :


# Defaults for config options defined in CONFIG
Vagrant.require_version '>= 1.6.0'
MOUNT_POINTS           = YAML::load_file('synced_folders.yml')
core_hostname          = 'master1'
update_channel         = 'alpha'
image_version          = 'current'
forwarded_ports        = {}

# DEPRECATED
#enable_serial_logging  = false
#share_home             = false
#linux_shared_folders   = {}
#windows_shared_folders = {}
#num_instances          = 1



# require and plugins
# ===================
require 'fileutils'
require './bootstrap_scripts/helpers.rb'

required_plugins = %w(vagrant-triggers vagrant-reload)
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



# Start project
# =============
# Import config file
unless File.exist?('./config.rb')
  puts <<-EOT
  you need to prepare the config.sh file first
    => open config.sh in the editor of your choice
       report to the project README.md for instructions
  EOT
  FileUtils.copy('./templates/template.config.rb',          'config.rb')
  FileUtils.copy('./templates/template.synced_folders.yml', 'synced_folders.yml')
  exit 1
end
require './config.rb'



# Control id_rsa mod to enable ssh
unless File.exist?('id_rsa')
  puts <<-EOT
  you need to an ssh key
    - add id_rsa to the main folder
  EOT
  exit 1
end
FileUtils.chmod 600, 'id_rsa'




unless File.exist?('auto_generated')
  FileUtils.mkdir 'auto_generated'
end
FileUtils.rm 'auto_generated/*', :force => true



require './bootstrap_scripts/prepare_cloud_config.rb'
require './bootstrap_scripts/prepare_kubernetes.rb'



# Start th VM
# ===========
Vagrant.configure('2') do |config|
  # always use Vagrants insecure key
  config.ssh.insert_key = true

  # =============== IMAGE
  # =============================================
  config.vm.box = "coreos-#{update_channel}"
  if image_version != 'current'
      config.vm.box_version = image_version
  end
  config.vm.box_url = "http://#{update_channel}.release.core-os.net/amd64-usr/#{image_version}/coreos_production_vagrant.json"


  # plugin conflict
  if Vagrant.has_plugin?('vagrant-vbguest')
    config.vbguest.auto_update = false
  end

  config.vm.define vm_name = core_hostname do |config|
    config.vm.hostname = core_hostname
    config.vm.provider :virtualbox do |vb|
      vb.check_guest_additions = false
      vb.functional_vboxsf     = false
      vb.gui                   = false
      vb.memory                = $vm_memory
      vb.cpus                  = $vm_cpus
      vb.customize ['modifyvm', :id, '--vram', '24']
    end


    # =============== NETWORK
    # =============================================

    # forward ports

    forwarded_ports.each do |guest, host|
      config.vm.network 'forwarded_port', guest: guest, host: host, auto_correct: true
    end

    # public network
    #   - network used bt the cluster
    config.vm.network :public_network,
                      bridge: $public_network_to_use

    # private network :
    #   - needed by nfs
    #   - request admin privilege window
    ip_private = '172.16.1.100'
    config.vm.network :private_network, ip: ip_private

    # =============== SHARED FOLDERS
    # =============================================
    begin
      MOUNT_POINTS.each do |mount|
        mount_options = ''
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
    if $shell_to_install == 'zsh'
      config.vm.provision :shell, :inline => 'rm /home/core/.bashrc'

      config.vm.provision :file, :source => 'templates/zsh/.bashrc',    :destination => '/home/core/.bashrc'
      config.vm.provision :file, :source => 'templates/zsh/.zshrc',     :destination => '/home/core/.zshrc'
      config.vm.provision :file, :source => 'templates/zsh/zsh',        :destination => '/home/core/zsh'
      config.vm.provision :file, :source => 'templates/zsh/.oh-my-zsh', :destination => '/home/core/.oh-my-zsh'

      config.vm.provision :shell, :inline => 'chmod 755 /home/core/zsh/bin/zsh'
    end

    # BASH
    if $shell_to_install == 'bash'
      config.vm.provision :shell, :inline => 'rm /home/core/.bashrc'
      config.vm.provision :file,  :source => 'templates/bash/.bashrc',
                                  :destination => '/home/core/.bashrc'
    end

    config.vm.provision :file, :source => 'templates/.commonrc', :destination => '/home/core/.commonrc'


    # ================== KUBERNETES
    # ==============================================

    # kubernetes manifests
    # ====================
    config.vm.provision :shell, keep_color: true,
                        :inline => 'mkdir -p /etc/kubernetes/manifests'

    if (defined? $master_hostname) == nil
      # --apiserver
      config.vm.provision :file, :source => 'auto_generated/kubernetes/kube-apiserver.yml',
                          :destination => '/tmp/kube-apiserver.yml'

      config.vm.provision :shell, keep_color: true,
                          :inline => 'mv /tmp/kube-apiserver.yml /etc/kubernetes/manifests/kube-apiserver.yml'

      # --controller
      config.vm.provision :file, :source => 'auto_generated/kubernetes/kube-controller.yml',
                          :destination => '/tmp/kube-controller.yml'

      config.vm.provision :shell, keep_color: true,
                          :inline => 'mv /tmp/kube-controller.yml /etc/kubernetes/manifests/kube-controller.yml'

      # --scheduler
      config.vm.provision :file, :source => 'auto_generated/kubernetes/kube-scheduler.yml',
                                 :destination => '/tmp/kube-scheduler.yml'

      config.vm.provision :shell, keep_color: true,
                          :inline => 'mv /tmp/kube-scheduler.yml /etc/kubernetes/manifests/kube-scheduler.yml'
    else
      # --node_kubeconfig
      config.vm.provision :file, :source => 'auto_generated/kubernetes/node_kubeconfig.yml',
                          :destination => '/tmp/node_kubeconfig.yml'

      config.vm.provision :shell, keep_color: true,
                          :inline => 'mv /tmp/node_kubeconfig.yml /etc/kubernetes/node_kubeconfig.yml'
    end

    # --proxy
    config.vm.provision :file, :source => 'auto_generated/kubernetes/kube-proxy.yml',
                        :destination => '/tmp/kube-proxy.yml'

    config.vm.provision :shell, keep_color: true,
                        :inline => 'mv /tmp/kube-proxy.yml /etc/kubernetes/manifests/kube-proxy.yml'


    # certificates
    # ============
    config.vm.provision :shell, keep_color: true,
                        :inline => "mkdir -p #{$kubernetes_ssl_path}"

    config.vm.provision :file, :source => "#{$ca_pem}",
                        :destination =>   "/tmp/#{$ca_pem_name}"

    if (defined? $master_hostname) == nil
      # MASTER
      config.vm.provision :file, :source => "#{$apiserver_pem}",
                          :destination =>   "/tmp/#{$apiserver_pem_name}"

      config.vm.provision :file, :source => "#{$apiserver_key_pem}",
                          :destination =>   "/tmp/#{$apiserver_key_pem_name}"

      config.vm.provision :shell, :privileged => true,
          inline: <<-EOF
          mv /tmp/#{$ca_pem_name}            #{$kubernetes_ssl_path}
          mv /tmp/#{$apiserver_pem_name}     #{$kubernetes_ssl_path}
          mv /tmp/#{$apiserver_key_pem_name} #{$kubernetes_ssl_path}
          EOF
    else
      # NODE
      config.vm.provision :file, :source => "#{$worker_pem}",
                          :destination =>   "/tmp/#{$worker_pem_name}"

      config.vm.provision :file, :source => "#{$worker_key_pem}",
                          :destination =>   "/tmp/#{$worker_key_pem_name}"

      config.vm.provision :file, :source => "#{$admin_pem}",
                          :destination =>   "/tmp/#{$admin_pem_name}"

      config.vm.provision :file, :source => "#{$admin_key_pem}",
                          :destination =>   "/tmp/#{$admin_key_pem_name}"

      config.vm.provision :shell, :privileged => true,
          inline: <<-EOF
          mv /tmp/#{$ca_pem_name}         #{$kubernetes_ssl_path}
          mv /tmp/#{$worker_pem_name}     #{$kubernetes_ssl_path}
          mv /tmp/#{$worker_key_pem_name} #{$kubernetes_ssl_path}
          mv /tmp/#{$admin_pem_name}      #{$kubernetes_ssl_path}
          mv /tmp/#{$admin_key_pem_name}  #{$kubernetes_ssl_path}
          EOF
    end


    # ================== CLOUD-CONFIG
    # ==============================================
    config.vm.provision :file, :source => 'auto_generated/cloud_config.yml',
                               :destination => '/tmp/vagrantfile-user-data'

    # config.vm.provision :file, :source => 'cloud_config2.yml',
    #                            :destination => '/tmp/vagrantfile-user-data'

    config.vm.provision :shell, :inline => 'mv /tmp/vagrantfile-user-data /var/lib/coreos-vagrant/'
  end
end

