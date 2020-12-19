#!/bin/bash

# Date update scriprt: 16.11.2020

echo "############################################"
echo "step 1: remove old version:"
echo "############################################"

sudo apt-get remove docker docker-engine docker.io containerd runc -y


echo "############################################"
echo "step 2: Update the apt package index:"
echo "############################################"

sudo apt-get update -y


echo "############################################"
echo "step 3: install packages to allow apt to use a repository over HTTPS:"
echo "############################################"

sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common -y


echo "############################################"
echo "step 4: Add Docker’s official GPG key:"
echo "############################################"

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -


echo "############################################"
echo "step 5: Set up the stable repository:"
echo "############################################"

sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"


echo "############################################"
echo "step 6: Update the apt package index:"
echo "############################################"

sudo apt-get update


echo "############################################"
echo "step 7: Set up the stable repository:"
echo "############################################"

sudo apt-get install -y docker-ce docker-ce-cli containerd.io

echo "############################################"
echo "############################################"
echo "############################################"
echo "Finish: Docker installed!"
echo "############################################"
echo "############################################"