# Linux installation script 

This is my personal linux provision script.

## Step 1 : OS Installation

Install OS using ISO

### Arch

Follow **README** in `arch_install_script` folder.

### Debian

For debian, install debian usign debian iso. Enable openssh in livecd. Create a user named **xhuang**. After installation, add **xhuang** to **sudo** group.

## Step 2: Post-installation

Use ansible to provision the OS

### Generate a ssh key and copy key to remote

```bash
ssh-keygen -f $HOME/.ssh/id_rsa
ssh-copy-id -i $HOME/.ssh/id_rsa USERNAME@HOST
```

### Update inventory list

Go to `hosts.ini`, change the ip of the remote machine

### Run ansible-playbook

```
virtualenv ansible
cd ansible
source ./bin/activate
pip3 install ansible
ansible-playbook -i ../hosts.ini provision.yaml --ask-become-pass --private-key  $HOME/.ssh/id_rsa
```

## Docker container

In the repo there is a `Dockerfile` that you can use to build a docker image. That image contains ansible and the playbook. Instead of installing ansible locally, you can use this docker image to run ansible

```
docker build -t alpine:ansible .
docker container run -it --name ansible alpine:ansible /bin/sh
ssh-keygen -f $HOME/.ssh/id_rsa
ssh-copy-id -i $HOME/.ssh/id_rsa USERNAME@HOST
cd /root
ansible-playbook -i ./hosts.ini provision.yaml --ask-become-pass --private-key  $HOME/.ssh/id_rsa
```