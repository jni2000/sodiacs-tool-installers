#!/bin/bash

set -e

IMAGE_NAME="jni2000/emba"
IMAGE_LABEL="1.5.2jni-staging-latest"
echo "==> Start SODIACS emba installation for extended vulnerability scan...."

# Install Docker on Ubuntu when missing, then verify the daemon is up.
ensure_docker() {
  if command -v docker >/dev/null 2>&1; then
    echo "==> Docker is already installed."
  else
    echo "==> Docker not found. Installing Docker..."
    [ -f /etc/os-release ] && . /etc/os-release
    [ "${ID:-}" = "ubuntu" ] || {
      echo "Error: Docker is missing and automatic install is only supported on Ubuntu."
      exit 1
    }
    sudo apt-get update
    sudo apt-get install -y docker.io
    echo "==> Docker installed."
  fi
  sudo systemctl enable --now docker
  sudo docker info >/dev/null
}

ensure_docker

cd ~/workspace/software-scanning
sudo rm -fr emba-temp
echo "==> Get the latest emba release."
git clone https://github.com/jni2000/emba.git emba-temp

# list and remove old emba docker images
echo "==> Remove prior emma container images."
sudo docker images --filter=reference="${IMAGE_NAME}:*"
# docker images --filter=reference="${IMAGE_NAME}:*" -q
# docker images --filter=reference="${IMAGE_NAME}:*" \
#   --format '{{.Repository}}:{{.Tag}}'
sudo docker images --filter=reference="${IMAGE_NAME}:*" -q | sort -u | xargs -r sudo docker rmi -f
sudo docker images --filter=reference="${IMAGE_NAME}" -q | sort -u | xargs -r sudo docker rmi -f

echo "==> Get the latest emba container image."
sudo docker image pull "${IMAGE_NAME}:${IMAGE_LABEL}"
# docker image pull "${IMAGE_NAME}:latest"

echo "==> Backup the prior emba installation."

DIR="emba"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
NEW_DIR="${DIR}-${TIMESTAMP}"

if [ ! -d "$DIR" ]; then
  echo "Error: directory '$DIR' does not exist."
  exit 1
fi

mv "$DIR" "$NEW_DIR"
echo "Renamed '$DIR' → '$NEW_DIR'"

echo "==> Install the latest emba release."
sudo mv emba-temp emba
cd emba
git checkout staging
chmod +x installer.sh
sudo ./installer.sh -d

echo "==> Test the new emba installation."
sudo ./emba -V

echo "<== Finished emba installation."
