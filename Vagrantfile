# -*- mode: ruby -*-
# # vi: set ft=ruby :

require 'fileutils'

Vagrant.require_version ">= 1.6.0"

#CLOUD_CONFIG_PATH = File.join(File.dirname(__FILE__), "cloud-config.yml")
BASHRC = File.join(File.dirname(__FILE__), "templates/.bashrc")
CONFIG = File.join(File.dirname(__FILE__), "vagrant_config.rb")
MOUNT_POINTS = YAML::load_file('vagrant_synced_folders.yaml')

# Defaults for config options defined in CONFIG
$num_instances = 1
$instance_name_prefix = "core"
$update_channel = "alpha"
$image_version = "current"
$enable_serial_logging = false
$share_home = false
$vm_gui = false
$vm_memory = 1024
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


required_plugins = %w(vagrant-triggers)

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

# Attempt to apply the deprecated environment variable NUM_INSTANCES to
# $num_instances while allowing config.rb to override it
if ENV["NUM_INSTANCES"].to_i > 0 && ENV["NUM_INSTANCES"]
  $num_instances = ENV["NUM_INSTANCES"].to_i
end

if File.exist?(CONFIG)
  require CONFIG
end

# Use old vb_xxx config variables when set
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
  config.ssh.insert_key = false
  config.ssh.username


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

  config.vm.define vm_name = $instance_name_prefix do |config|
    config.vm.hostname = vm_name


    # =============== NETWORK
    # =============================================
    if $expose_docker_tcp
      config.vm.network "forwarded_port", guest: 2375, host: $expose_docker_tcp, auto_correct: true
    end

    $forwarded_ports.each do |guest, host|
      config.vm.network "forwarded_port", guest: guest, host: host, auto_correct: true
    end

    config.vm.provider :virtualbox do |vb|
      vb.gui = vm_gui
      vb.memory = vm_memory
      vb.cpus = vm_cpus
    end

    ip_private = "172.16.1.14"
    config.vm.network :private_network, ip: ip_private
    ip_public = "192.168.1.14"
    config.vm.network :public_network, ip: ip_public


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

    # if File.exist?(CLOUD_CONFIG_PATH)
    #   config.vm.provision :file, :source => "#{CLOUD_CONFIG_PATH}", :destination => "/tmp/vagrantfile-user-data"
    #   config.vm.provision :shell, :inline => "mv /tmp/vagrantfile-user-data /var/lib/coreos-vagrant/", :privileged => true
    # end

    # =============== BASHRC
    # =============================================
    config.vm.provision :shell, :inline => "rm /home/core/.bashrc"
    config.vm.provision :file, :source => "templates/.bashrc",    :destination => "/home/core/.bashrc"
    config.vm.provision :file, :source => "templates/.zshrc",     :destination => "/home/core/.zshrc"
    config.vm.provision :file, :source => "templates/zsh",        :destination => "/home/core/zsh"
    config.vm.provision :file, :source => "templates/.oh-my-zsh", :destination => "/home/core/.oh-my-zsh"
  end
end
