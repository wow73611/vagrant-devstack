# DevStack in a Vagrant VM with Ansible

This repository contains a Vagrantfile and an Ansible playbook
that sets up a VirtualBox virtual machine that installs [DevStack][4].


You can configure devstack services by editing the playbook.yml file.


## Prereqs

Install the following applications on your local machine first:

 * [VirtualBox][5]
 * [Vagrant][2]
 * [Ansible][3]


Example for ubuntu 14.04 enviroment:
 
- Linux Ubuntu 14.04
- VirutalBox >= 5.0
- Vagrant >= 1.5.0
- ansible >= 1.8.0

Install VirtualBox
```
$ sh -c "echo 'deb http://download.virtualbox.org/virtualbox/debian '$(lsb_release -cs)' contrib' > /etc/apt/sources.list.d/virtualbox.list"
$ wget -q http://download.virtualbox.org/virtualbox/debian/oracle_vbox.asc -O- | sudo apt-key add -
$ sudo apt-get update
$ sudo apt-get install -y virtualbox-5.1
```

Install Vagrant
```
$ wget https://releases.hashicorp.com/vagrant/1.8.7/vagrant_1.8.7_x86_64.deb
$ sudo dpkg -i vagrant_1.8.7_x86_64.deb
```

Install dependencies
```
$ sudo apt-get install -y python-dev python-virtualenv
$ sudo apt-get install -y libssl-dev libffi-dev
```


## Boot the virtual machine and install DevStack

Grab this repo and do a `vagrant up`, like so:

```bash
git clone https://github.com/wow73611/vagrant-devstack
cd vagrant-devstack
vagrant up
vagrant status
vagrant ssh
vagrant halt
vagrant destroy
```


The Vagrantfile use config.yml file as default configuration.
You can define another configuration file by the following: 

```bash
export USER_CONF=my.yml && vagrant up

or

USER_CONF=my.yml vagrant up
```

## Horizon

* URL: http://192.168.10.101
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

