#!/bin/sh
sudo apt-get update
sudo apt-get -y install apache2 libxml2-dev

sudo ufw --force enable   
sudo ufw allow 80/tcp
sudo ufw allow ssh

echo "ServerName localhost" >> /etc/apache2/apache2.conf
sudo service apache2 restart

sudo rm /etc/apache2/sites-available/000-default.conf

sudo service apache2 reload

sudo apt-get -y install docker
sudo apt-get -y install docker.io
