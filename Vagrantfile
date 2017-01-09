# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2" if not defined? VAGRANTFILE_API_VERSION

conf = {
    'box_name' => 'ubuntu/xenial64',
    'box_url' => '',
    'box_hostname' => 'devstack',
    'vm_memory' => 8192,
    'vm_cpus' => 4,
#   'proxy' => 'http://192.168.1.1',
#   'local_sync_folder' => './opt',
    'internal_ip' => '172.20.1.11',
    'external_ip' => '172.20.2.1',
}

require 'yaml'
if File.file?('config.yaml')
    user_conf = YAML.load_file('config.yaml')
    conf.update(user_conf)
else
    raise "Configuration file 'config.yaml' does not exist."
end

def config_network(vm, conf)
    # this will be the endpoint
    vm.network :private_network, ip: conf['internal_ip']
    # this will be the OpenStack "public" network ip and subnet mask
    # should match floating_ip_range var in devstack.yml
    vm.network :private_network, ip: conf['external_ip'], :netmask => "255.255.255.0", :auto_config => false
    vm.network :forwarded_port, guest: 80, host: 8080
end

def config_provider(vm, conf)
    vm.provider :virtualbox do |vb|
        vb.customize ["modifyvm", :id, "--memory", conf['vm_memory']]
        vb.customize ["modifyvm", :id, "--cpus", conf['vm_cpus']]
       	# eth2 must be in promiscuous mode for floating IPs to be accessible
       	vb.customize ["modifyvm", :id, "--nicpromisc3", "allow-all"]
    end
end

def config_provision(vm, conf)
    vm.provision :ansible do |ansible|
        ansible.host_key_checking = false
        ansible.playbook = "playbook.yml"
        ansible.verbose = "vv"
        #ansible.extra_vars = {}
    end
    vm.provision :shell, :inline => "cd /opt/devstack; sudo -u ubuntu env HOME=/home/ubuntu ./stack.sh"
    # interface should match external_interface var in devstack.yml
    #vm.provision :shell, :inline => "ovs-vsctl add-port br-ex enp0s9"
    #vm.provision :shell, :inline => "virsh net-destroy default"
end

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

    config.vm.box = conf['box_name']
    config.vm.box_url = conf['box_url'] if conf['box_url']
    config.vm.hostname = conf['box_hostname']

    if Vagrant.has_plugin?("vagrant-cachier")
        config.cache.scope = :box
    end

    if Vagrant.has_plugin?("vagrant-proxyconf") && conf['proxy']
        config.proxy.http     = conf['proxy']
        config.proxy.https    = conf['proxy']
        config.proxy.no_proxy = "localhost,127.0.0.1"
    end

    # resolve "stdin: is not a tty warning", related issue and proposed 
    # fix: https://github.com/mitchellh/vagrant/issues/1673
    config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"
    config.ssh.forward_agent = true

    config_network(config.vm, conf)
    config_provider(config.vm, conf)
    config_provision(config.vm, conf)

    if conf['local_sync_folder']
        config.vm.synced_folder conf['local_sync_folder'], "/opt"
    end
end

