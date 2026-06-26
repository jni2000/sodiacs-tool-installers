#!/bin/bash

# Exit immediately if any step throws an error
set -e

echo "=== Checking Python 3.12 Environment ==="

# 1. Condition check: Check if python3.12 command is already available
if command -v python3.12 >/dev/null 2>&1; then
    echo "Notice: Python 3.12 is already installed on your system. Skipping compilation."
    echo "=========================================================="
    echo " CURRENT ENVIRONMENT SUMMARY:"
    echo "=========================================================="
    echo "Default 'python3' target profile: $(python3 -V 2>&1)"
    echo "Explicit binary mapping:          $(which python3.12) ($(python3.12 -V 2>&1))"
    echo "Associated isolated pip target:   $(command -v pip3.12 >/dev/null 2>&1 && pip3.12 -V || echo 'Not linked')"
    echo "=========================================================="
    exit 0
fi

echo "Python 3.12 not found. Beginning clean side-by-side compilation..."

# 2. Fetch system build development dependencies
echo "Installing compilation prerequisites..."
sudo apt update
sudo apt install -y build-essential zlib1g-dev libncurses5-dev libgdbm-dev \
                    libnss3-dev libssl-dev libreadline-dev libffi-dev \
                    libsqlite3-dev libbz2-dev liblzma-dev wget

# 3. Download Python 3.12 source distribution tarball 
# (Updated to the current stable security release package tracking)
cd /tmp
echo "Downloading Python 3.12 tarball asset..."
wget -q --show-progress https://www.python.org/ftp/python/3.12.13/Python-3.12.13.tgz

# 4. Extract source files
echo "Extracting Python environment files..."
tar -xf Python-3.12.13.tgz
cd Python-3.12.13

# 5. Prepare compilation paths with performance enhancements
echo "Configuring Python source properties..."
./configure --enable-optimizations --with-ensurepip=install

# 6. Compile utilizing all active system CPU processing cores
echo "Compiling code binaries (this may take several minutes)..."
make -j$(nproc)

# 7. Install using ALTINSTALL to completely shield default python3.10 configurations
echo "Performing safe secondary installation..."
sudo make altinstall

# 8. Map explicit execution shortcut directly into /usr/bin/
echo "Mapping symbolic executable tracking pointer into /usr/bin/python3.12..."
sudo ln -sf /usr/local/bin/python3.12 /usr/bin/python3.12

# 9. Post-install environment configuration validation check
echo "=========================================================="
echo " SUCCESS: VERIFICATION CHECKS:"
echo "=========================================================="
echo "Default 'python3' target profile: $(python3 -V 2>&1)"
echo "Target explicit binary mapping:   $(/usr/bin/python3.12 -V 2>&1)"
echo "Associated isolated pip target:   $(pip3.12 -V 2>&1)"
echo "=========================================================="

