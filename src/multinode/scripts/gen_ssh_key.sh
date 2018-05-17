#!/bin/bash

rm -rf /vagrant/id_rsa
sudo ssh-keygen -f /vagrant/id_rsa -t rsa -N ''
