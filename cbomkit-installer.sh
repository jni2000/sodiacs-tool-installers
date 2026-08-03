#!/bin/bash

# Exit immediately if any command fails
set -e

# install or upgrade go to 25 or late
chmod +x update_go.sh
./update_go.sh


TARGET_DIR="$HOME/workspace/software-scanning"
mkdir -p "$TARGET_DIR"
cd "$TARGET_DIR"

git clone https://github.com/cbomkit/cbomkit-theia.git
 
cd cbomkit-theia/
go mod download
go build
