#!/bin/bash

UBUNTU_USER=ubuntu
UBUNTU_DEFAULT_HOSTNAME=ubuntu.local

# On your laptop
ssh ${UBUNTU_USER?}@${UBUNTU_DEFAULT_HOSTNAME?}
ssh-copy-id ubuntu@${UBUNTU_DEFAULT_HOSTNAME?}

# On the box
ssh ${UBUNTU_USER?}@${UBUNTU_DEFAULT_HOSTNAME?}
mkdir -p ~/.kube/
scp ~/.kube/config ${UBUNTU_USER?}@${UBUNTU_DEFAULT_HOSTNAME?}:~/.kube/

# Python 3.8 for now
sudo apt-get update
sudo apt-get install -y software-properties-common
sudo apt-get install -y python3 python3-distutils python-is-python3

# Pip
export PATH=${PATH}:${HOME}/.local/bin
echo 'export PATH=${PATH}:${HOME}/.local/bin' >> ~/.bashrc
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python get-pip.py --user

pip install ansible
pip install ipython

