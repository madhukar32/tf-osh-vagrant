#!/bin/bash

sudo su
mkdir -p /root/.ssh
touch -a /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys
sudo bash -c "cat /vagrant/id_rsa.pub >> /root/.ssh/authorized_keys"
