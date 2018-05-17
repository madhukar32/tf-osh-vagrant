#!/bin/bash


touch /home/vagrant/.ansible.cfg
tee /home/vagrant/.ansible.cfg << EOF
[defaults]
host_key_checking = no
EOF
