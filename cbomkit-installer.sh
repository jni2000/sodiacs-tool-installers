#!/bin/bash

# Exit immediately if any command fails
set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# install or upgrade go to 25 or late
chmod +x "$SCRIPT_DIR/update_go.sh"
"$SCRIPT_DIR/update_go.sh"


TARGET_DIR="$HOME/workspace/software-scanning"
mkdir -p "$TARGET_DIR"
cd "$TARGET_DIR"

git clone git@github.com:jni2000/cbomkit-theia.git
 
cd cbomkit-theia
git checkout main
go mod download
go build
