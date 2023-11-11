#!/bin/sh

# URL
imageURL="https://l.hpclab.kr/stcimage"
stcURL="https://l.hpclab.kr/stcbuildlinux"

# CONFIG
mode="idle"
idleThreshold=300

# DOCKER-CONFIG
imageName="stc-image"
containerName="stc-container"

echo "[stc] Install prerequisites..."
apt-get update && apt-get install tmux curl tar jq xprintidle tmux -y
if ! [ -x "$(command -v docker)" ]; then
  echo '[stc] Docker is not installed. Start the installation.'
  # Add Docker's official GPG key:
  apt-get update
  apt-get install ca-certificates curl gnupg
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  chmod a+r /etc/apt/keyrings/docker.gpg

  # Add the repository to Apt sources:
  echo \
    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" |
    tee /etc/apt/sources.list.d/docker.list >/dev/null
  apt-get update
  apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
fi

echo "[stc] Install stc files..."
user=$(logname)
raw_home=$(getent passwd "$user" | cut -d: -f6)
home=$(realpath -s "$raw_home")
usermod -aG docker "$user"
rm -rf /opt/stc
mkdir /opt/stc -p
jq -n \
  --arg mode "$mode" \
  --argjson idleThreshold "$idleThreshold" \
  '{mode: $mode, idleThreshold: $idleThreshold}' >"/opt/stc/config.json"
jq -n \
  --arg imageName "$imageName" \
  --arg containerName "$containerName" \
  '{imageName: $imageName, containerName: $containerName}' >"/opt/stc/docker-config.json"
curl -L -o /opt/stc/image.tar "$imageURL"
sh -c "docker rm --force $containerName 2> /dev/null"
sh -c "docker rmi --force $imageName 2> /dev/null"
sh -c "docker load -i /opt/stc/image.tar"
sh -c "docker create --gpus all --privileged -it --entrypoint '/opt/run.sh' --name $containerName $imageName"
rm /opt/stc/image.tar
curl -L -o /opt/stc/stc.tar "$stcURL"
tar -xvf /opt/stc/stc.tar -C /opt/stc
chown "$user" /opt/stc -R
chmod 764 -R /opt/stc
mkdir "$home/.config/autostart" -p
cp /opt/stc/stc.desktop "$home/.config/autostart/"
echo "[stc] Install done!"