#!/bin/bash

# Exit immediately if any command fails
set -e

TARGET_DIR="$HOME/workspace/software-scanning"
mkdir -p "$TARGET_DIR"
cd "$TARGET_DIR"

git clone https://github.com/cbomkit/cbomkit-theia.git
 
cd cbomkit-theia/
go mod download
go build
