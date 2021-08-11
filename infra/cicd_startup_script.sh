#!/bin/bash

sudo apt-get update

sudo apt-get --yes install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

#Add Docker’s official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

sudo apt install --yes docker.io make

#create app-src directory to host static files
mkdir -p /codetest/app_src
chmod 777 -R /codetest/