#!/bin/sh

# CONFIG
imageURL="https://l.hpclab.kr/stcimage"
imageName="stc-image",
containerName="stc-container"

mode="idle"
idleThreshold=300

echo "Install prerequisites..."
sudo apt-get update && sudo apt-get install tmux wget tar jq -y
if ! [ -x "$(command -v docker)" ]; then
    echo 'Docker is not installed. Start the installation.'
    # Add Docker's official GPG key:
    sudo apt-get update
    sudo apt-get install ca-certificates curl gnupg
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg

    # Add the repository to Apt sources:
    echo \
      "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
fi
sudo useradd -M stc
sudo usermod -aG docker stc
sudo mkdir /opt/stc -p
sudo wget $imageURL -o /opt/stc/image.tar
sudo docker load -i /opt/stc/image.tar
sudo rm /opt/stc/image.tar

# 압축 풀기

