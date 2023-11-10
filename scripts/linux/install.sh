#!/bin/sh

# URL
imageURL="https://l.hpclab.kr/stcimage"

# CONFIG
mode="idle"
idleThreshold=300

# DOCKER-CONFIG
imageName="stc-image",
containerName="stc-container"

echo "[stc] Install prerequisites..."
sudo apt-get update && sudo apt-get install tmux wget tar jq inotify-tools xprintidle -y
if ! [ -x "$(command -v docker)" ]; then
  echo '[stc] Docker is not installed. Start the installation.'
  # Add Docker's official GPG key:
  sudo apt-get update
  sudo apt-get install ca-certificates curl gnupg
  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  sudo chmod a+r /etc/apt/keyrings/docker.gpg

  # Add the repository to Apt sources:
  echo \
    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" |
    sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
  sudo apt-get update
  sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
fi

echo "[stc] Install stc files..."
user=$(sudo logname)
sudo usermod -aG docker "$user"
sudo rm -rf /opt/stc
sudo mkdir /opt/stc -p
sudo jq -n \
  --arg mode "mode" \
  --arg idleThreshold "idleThreshold" \
  '{mode: $mode, idleThreshold: $idleThreshold}' >"/opt/stc/config.json"
sudo jq -n \
  --arg imageName "$imageName" \
  --arg containerName "$containerName" \
  '{imageName: $imageName, containerName: $containerName}' >"/opt/stc/docker-config.json"
sudo curl -L -o /opt/stc/image.tar "$imageURL"
sh -c "docker load -i /opt/stc/image.tar"
rm /opt/stc/image.tar
sudo chown "$user" /opt/stc -R

echo "[stc] Install done!"
