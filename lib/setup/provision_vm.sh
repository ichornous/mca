#!/bin/sh
# Update repositories
sudo apt-get update -y
sudo apt-get upgrade -y

# Install ruby
sudo su - vagrant -c 'curl -sSL https://rvm.io/mpapis.asc | gpg --import -'
sudo su - vagrant -c 'curl -sSL https://get.rvm.io | bash -s stable --ruby'
sudo su - vagrant -c 'rvm rvmrc warning ignore allGemfiles'
sudo su - vagrant -c '. $HOME/.rvm/scripts/rvm && rvm use --default --install 2.3.0 rails'

curl -sL https://deb.nodesource.com/setup | sudo bash -

sudo apt-get install -y nodejs
sudo apt-get install -y git
sudo apt-get install -y libpq-dev
sudo apt-get install -y build-essential

sudo su - vagrant npm install -g bower

sudo npm config set prefix /usr/local
sudo npm install -g bower

# Install bundler and bundle install
sudo su - vagrant -c 'gem install bundler'
sudo su - vagrant -c 'cd /vagrant && bundle install'

# Install Docker
# wget -qO- https://get.docker.com/gpg | sudo apt-key add -
# wget -qO- https://get.docker.com/ | sh
# sudo usermod -aG docker vagrant
