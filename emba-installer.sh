#!/bin/bash

set -e

IMAGE_NAME="jni2000/emba"
IMAGE_LABEL="1.5.2jni-staging-latest"
echo "==> Start SODIACS emba installation for extended vulnerability scan...."

# Install Docker (and Compose if needed) on Ubuntu when missing, then verify the daemon is up.
require_ubuntu() {
  [ -f /etc/os-release ] && . /etc/os-release
  [ "${ID:-}" = "ubuntu" ] || {
    echo "Error: $1 is missing and automatic install is only supported on Ubuntu."
    exit 1
  }
}

ensure_docker() {
  local pkgs=()
  local installing_docker=0

  if command -v docker >/dev/null 2>&1; then
    echo "==> Docker is already installed."
  else
    echo "==> Docker not found. Will install Docker..."
    require_ubuntu "Docker"
    pkgs+=(docker.io)
    installing_docker=1
  fi

  # If Docker is not installed yet, probe only for the standalone binary.
  # Otherwise prefer `docker compose` (v2 plugin), then `docker-compose`.
  if ((installing_docker)); then
    if command -v docker-compose >/dev/null 2>&1; then
      echo "==> docker-compose is already installed."
    else
      echo "==> Docker Compose not found. Will install docker-compose-v2..."
      require_ubuntu "Docker Compose"
      pkgs+=(docker-compose-v2)
    fi
  elif sudo docker compose version >/dev/null 2>&1; then
    echo "==> Docker Compose is already installed."
  elif command -v docker-compose >/dev/null 2>&1; then
    echo "==> docker-compose is already installed."
  else
    echo "==> Docker Compose not found. Will install docker-compose-v2..."
    require_ubuntu "Docker Compose"
    pkgs+=(docker-compose-v2)
  fi

  if ((${#pkgs[@]})); then
    sudo apt-get update
    sudo apt-get install -y "${pkgs[@]}"
    echo "==> Installed: ${pkgs[*]}"
  fi

  sudo systemctl enable --now docker
  sudo docker info >/dev/null

  if sudo docker compose version >/dev/null 2>&1; then
    echo "==> Docker Compose OK."
  elif command -v docker-compose >/dev/null 2>&1; then
    echo "==> docker-compose OK."
  else
    echo "Error: Docker Compose is unavailable after install."
    exit 1
  fi

  echo "==> Adding ${USER} to the docker group..."
  sudo usermod -aG docker "${USER}"
}

ensure_docker

SCAN_ROOT="${HOME}/workspace/software-scanning"
mkdir -p "${SCAN_ROOT}"
cd "${SCAN_ROOT}"
sudo rm -fr emba-temp
echo "==> Get the latest emba release."
git clone https://github.com/jni2000/emba.git emba-temp

# list and remove old emba docker images
echo "==> Remove prior emba container images."
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

if [ -d "$DIR" ]; then
  mv "$DIR" "$NEW_DIR"
  echo "Renamed '$DIR' → '$NEW_DIR'"
else
  echo "==> No prior emba installation found; skipping backup."
fi

echo "==> Install the latest emba release."
sudo mv emba-temp emba
cd emba
git checkout staging
chmod +x installer.sh
sudo ./installer.sh -d

echo "==> Test the new emba installation."
sudo ./emba -V

echo "<== Finished emba installation."
