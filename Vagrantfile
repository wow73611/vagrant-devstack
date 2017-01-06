# -*- mode: ruby -*-
# vi: set ft=ruby :


DEVSTACK_IP = ENV["DEVSTACK_IP"] || "172.20.1.100"

Vagrant.configure("2") do |config|

    config.vm.box = "ubuntu/xenial64"
    config.vm.hostname = "devstack"

    # resolve "stdin: is not a tty warning", related issue and proposed 
    # fix: https://github.com/mitchellh/vagrant/issues/1673
    config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"
    config.ssh.forward_agent = true

    # eth1, this will be the endpoint
    config.vm.network :private_network, ip: DEVSTACK_IP
    # eth2, this will be the OpenStack "public" network
    # ip and subnet mask should match floating_ip_range var in devstack.yml
    config.vm.network :private_network, ip: "172.20.2.1", :netmask => "255.255.255.0", :auto_config => false
    # config.vm.network :forwarded_port, guest: 80, host: 8080

    config.vm.provider :virtualbox do |vb|
        vb.customize ["modifyvm", :id, "--memory", 8192]
        vb.customize ["modifyvm", :id, "--cpus", 4]
       	# eth2 must be in promiscuous mode for floating IPs to be accessible
       	vb.customize ["modifyvm", :id, "--nicpromisc3", "allow-all"]
    end
    #config.vm.provision :ansible do |ansible|
    #    ansible.host_key_checking = false
    #    ansible.playbook = "playbook.yml"
    #    ansible.verbose = "vv"
    #end
    #config.vm.provision :shell, :inline => "cd /opt/devstack; sudo -u ubuntu env HOME=/home/ubuntu ./stack.sh"
    # interface should match external_interface var in devstack.yml
    #config.vm.provision :shell, :inline => "ovs-vsctl add-port br-ex eth2"
    #config.vm.provision :shell, :inline => "virsh net-destroy default"

end

