# DevStack in a Vagrant VM with Ansible

This repository contains a Vagrantfile and an Ansible playbook
that sets up a VirtualBox virtual machine that installs [DevStack][4].


You can configure devstack services by editing the devstack.yml file.


## Prereqs

Install the following applications on your local machine first:

 * [VirtualBox][5]
 * [Vagrant][2]
 * [Ansible][3]


## Boot the virtual machine and install DevStack

Grab this repo and do a `vagrant up`, like so:

    git clone https://github.com/wow73611/vagrant-devstack
    cd vagrant-devstack
    vagrant up


## Horizon

* URL: http://172.20.1.100
* Username: admin or demo
* Password: password


## Allow VMs to connect to the internet (Linux hosts only)

By default, VMs started by OpenStack will not be able to connect to the
internet. If you want your VMs to connect out, and you are running Linux
as your host operating system, you must configure your host machine to do
network address translation (NAT).

To enable NAT, issue the following commands in your host, as root:

```bash
echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
```


## Initial networking configuration

![Network topology](topology.png)


DevStack configures an internal network ("private") and an external network ("public"), with a router ("router1") connecting the two together. The router is configured to use its interface on the "public" network as the gateway.


## Destroy VMs with vagrant command

    vagrant destroy --force && vagrant up


[1]: https://github.com/bcwaldon/vagrant_devstack
[2]: http://vagrantup.com
[3]: http://ansible.com
[4]: http://devstack.org
[5]: http://virtualbox.org
[6]: http://blog.nasmart.me/internet-access-with-virtualbox-host-only-networks-on-os-x-mavericks/
[7]: https://github.com/lorin/devstack-vm

