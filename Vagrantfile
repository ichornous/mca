# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty64"

  config.vm.network "forwarded_port", guest: 3000, host: 8300

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  config.vm.provider "virtualbox" do |vb|
    vb.memory = "2048"
    vb.cpus = "2"
  end

  config.vm.hostname = "mca-dev"
  config.vm.provision "shell" do |s|
    ssh_pub_key = File.readlines("#{Dir.home}/.ssh/id_rsa.pub").first.strip
    s.inline = <<-SHELL
      echo %vagrant ALL=NOPASSWD:ALL | sudo tee /etc/sudoers.d/vagrant > /dev/null

      sudo mkdir -p /home/vagrant/.ssh || true
      sudo touch /home/vagrant/.ssh/authorized_keys
      echo #{ssh_pub_key} | sudo tee /home/vagrant/.ssh/authorized_keys
      sudo chown -R vagrant:vagrant /home/vagrant
      sudo chmod 700 /home/vagrant/.ssh
      sudo chmod 600 /home/vagrant/.ssh/authorized_keys
    SHELL
  end

  config.vm.provision "shell", path: "./lib/setup/provision_vm.sh"
end
