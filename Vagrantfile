# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2" if not defined? VAGRANTFILE_API_VERSION

conf = {}

require 'yaml'
conf_path = ENV.fetch('USER_CONF','config.yml')
if File.file?(conf_path)
    user_conf = YAML.load_file(File.join(File.dirname(__FILE__),conf_path))
    conf.update(user_conf)
else
    raise "Configuration file #{conf_path} does not exist."
end

$network_conf= <<SCRIPT
echo "auto eth2
iface eth2 inet manual
up ip link set dev $IFACE up
down ip link set dev $IFACE down
" >> /etc/network/interfaces
SCRIPT

def config_network(vm, conf)
    # this will be the endpoint
    vm.network :private_network, ip: conf['host_ip']
    # this will be the OpenStack "public" network ip and subnet mask
    # should match floating_ip_range var in devstack.yml
    vm.network :private_network, ip: conf['public_ip'], :netmask => "255.255.255.0", :auto_config => false
    # Horizon
    vm.network :forwarded_port, guest: 80, host: 80
    # Keystone
    vm.network :forwarded_port, guest: 5000, host: 5000
    vm.network :forwarded_port, guest: 35357, host: 35357
    # Nova
    vm.network :forwarded_port, guest: 8774, host: 8774
    # Cinder
    vm.network :forwarded_port, guest: 8776, host: 8776
    # Glance
    vm.network :forwarded_port, guest: 9292, host: 9292
    # Neutron
    vm.network :forwarded_port, guest: 9696, host: 9696
    # VNC
    vm.network :forwarded_port, guest: 6080, host: 6080
end

def config_provider(vm, conf)
    vm.provider :virtualbox do |vb|
        vb.customize ["modifyvm", :id, "--cpus", conf['vm_cpus']]
        vb.customize ["modifyvm", :id, "--memory", conf['vm_memory']]
        vb.customize ["modifyvm", :id, "--ioapic", "on"]
        # eth2 must be in promiscuous mode for floating IPs to be accessible
        vb.customize ["modifyvm", :id, "--nicpromisc3", "allow-all"]

        # change the network card hardware for better performance
        vb.customize ["modifyvm", :id, "--nictype1", "virtio" ]
        vb.customize ["modifyvm", :id, "--nictype2", "virtio" ]

        # suggested fix for slow network performance
        # see https://github.com/mitchellh/vagrant/issues/1807
        vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
        vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]

    end
end

def config_provision(vm, conf)
    vm.provision :ansible do |ansible|
        ansible.host_key_checking = false
        ansible.playbook = "ansible/playbook.yml"
        ansible.verbose = "v"
        ansible.raw_arguments = ['-T 30', '-e pipelining=True']
        ansible.extra_vars = {
            host_ip: conf['host_ip'],
            public_ip: conf['public_ip'],
            public_interface: conf['public_interface'],
            openstack_version: conf['openstack_version'],
            devstack_branch: conf['devstack_branch'],
            devstack_service_branch: conf['devstack_service_branch'],
            devstack_admin_password: conf['devstack_admin_password'],

        }
    end
    vm.provision :shell, :inline => $network_conf
    #vm.provision :shell, :inline => "cd /opt/devstack; sudo -u stack ./stack.sh"
end

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    # resolve "stdin: is not a tty warning", related issue and proposed 
    # fix: https://github.com/mitchellh/vagrant/issues/1673
    config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"
    config.ssh.forward_agent = true

    config.vm.box = conf['box_name']
    config.vm.box_url = conf['box_url'] if conf['box_url']
    config.vm.hostname = conf['box_hostname']

    if Vagrant.has_plugin?("vagrant-cachier")
        config.cache.scope = :box
    end
    config_network(config.vm, conf)
    config_provider(config.vm, conf)
    config_provision(config.vm, conf)

    if conf['local_sync_folder']
        config.vm.synced_folder conf['local_sync_folder'], "/opt"
    end
end

