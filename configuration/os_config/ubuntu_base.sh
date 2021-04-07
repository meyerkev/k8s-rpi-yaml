#!/bin/bash

if [ -z $1 ]; then
    echo "MUST PROVIDE A NEW HOSTNAME"
    exit -1
fi
NEW_HOSTNAME=$1
UBUNTU_USER=ubuntu
UBUNTU_DEFAULT_HOSTNAME=ubuntu.local

# On your laptop
ssh ${UBUNTU_USER?}@${UBUNTU_DEFAULT_HOSTNAME?}
ssh-copy-id ubuntu@${UBUNTU_DEFAULT_HOSTNAME?}

# On the box
ssh ${UBUNTU_USER?}@${UBUNTU_DEFAULT_HOSTNAME?} "sudo hostnamectl set-hostname ${NEW_HOSTNAME?}; sudo reboot now"
