#!/bin/bash

UBUNTU_USER=ubuntu
# Things that can be moved to ansible:

# New apt repos
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

# Gotta do this manually on arm
# curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
# sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

# Install packages
sudo apt-get update && sudo apt-get full-upgrade -y
sudo apt-get install -y net-tools \
						docker.io \
						kubelet kubeadm kubectl \
						build-essential \ 
						# terraform  # Not on arm64 yet in packages
                        unzip
sudo apt-mark hold kubelet kubeadm kubectl

# Terraform
wget https://releases.hashicorp.com/terraform/0.14.9/terraform_0.14.9_linux_arm64.zip

unzip terraform_0.14.9_linux_arm64.zip
sudo cp terraform /usr/bin/terraform


# Enable Docker
sudo cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

sudo cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF


sudo sed -i '$ s/$/ cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1 swapaccount=1/' /boot/firmware/cmdline.txt

sudo hostnamectl set-hostname ${UBUNTU_HOSTNAME?}
sudo reboot now

# On the box again with new hostname post-reboot
ssh ${UBUNTU_USER?}@${UBUNTU_HOSTNAME?}


