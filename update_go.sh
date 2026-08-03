#!/bin/bash 

### Define the minimum major version required (e.g., 25 for 1.25)

MIN_VERSION=25 

### Fetch the latest stable Go version string dynamically from the official API

LATEST_VERSION=$(curl -s https://go.dev/VERSION?m=text | head -n 1) 

### Clean it up to just the version numbers (e.g., "1.26.5")

LATEST_NUM=(echo "LATEST_VERSION" | sed 's/go//') 

echo "Latest available Go version is: $LATEST_VERSION" 

### 1. Check if Go is installed at all

if ! command -v go &> /dev/null; then
echo "Go is not installed. Proceeding with fresh installation..."
else 

# 2. Extract the installed major version number (e.g., 24 from "go1.24.2")

INSTALLED_STR=$(go version | awk '{print $3}')
INSTALLED_MAJOR=(echo "INSTALLED_STR" | cut -d. -f2)

echo "Detected installed Go version: $INSTALLED_STR"

if [ "

INSTALLEDMAJOR"−ge"cap I cap N cap S cap T cap A cap L cap L cap E cap D sub cap M cap A cap J cap O cap R " minus g e "
𝐼𝑁𝑆𝑇𝐴𝐿𝐿𝐸𝐷𝑀𝐴𝐽𝑂𝑅"−𝑔𝑒"
MIN_VERSION" ]; then
echo "Success: Your Go version is up to date (Go 1.

INSTALLEDMAJOR>=1.cap I cap N cap S cap T cap A cap L cap L cap E cap D sub cap M cap A cap J cap O cap R is greater than equals 1.
𝐼𝑁𝑆𝑇𝐴𝐿𝐿𝐸𝐷𝑀𝐴𝐽𝑂𝑅>=1.
MIN_VERSION)."
exit 0
else
echo "Your Go version (1.

INSTALLEDMAJOR)isolderthantherequired1.cap I cap N cap S cap T cap A cap L cap L cap E cap D sub cap M cap A cap J cap O cap R close paren i s o l d e r t h a n t h e r e q u i r e d 1.
𝐼𝑁𝑆𝑇𝐴𝐿𝐿𝐸𝐷𝑀𝐴𝐽𝑂𝑅)𝑖𝑠𝑜𝑙𝑑𝑒𝑟𝑡ℎ𝑎𝑛𝑡ℎ𝑒𝑟𝑒𝑞𝑢𝑖𝑟𝑒𝑑1.
MIN_VERSION."
echo "Upgrading to $LATEST_VERSION..."
fi

fi 

### 3. Download and Install/Update Go

### Define temporary download location and the installation directory

TAR_FILE="/tmp/${LATEST_VERSION}.linux-amd64.tar.gz"
INSTALL_DIR="/usr/local" 

echo "Downloading ${LATEST_VERSION}..."
curl -L "https://go.dev/dl/
𝐿𝐴𝑇𝐸𝑆𝑇𝑉𝐸𝑅𝑆𝐼𝑂𝑁

.

𝑙𝑖𝑛𝑢𝑥

−𝑎𝑚𝑑64

.

𝑡𝑎𝑟

.

𝑔𝑧

"

−𝑜

"
TAR_FILE" 

echo "Removing any old Go installations and extracting new files..." 

### Safely wipe the old directory as recommended by Go documentation before extracting

sudo rm -rf "${INSTALL_DIR}/go"
sudo tar -C "
𝐼𝑁𝑆𝑇𝐴𝐿𝐿𝐷𝐼𝑅

"

−𝑥𝑧𝑓

"
TAR_FILE" 

### Clean up the downloaded tar file

rm "$TAR_FILE" 

### 4. Verify system environment PATH variables

if ! echo "PATH" | grep -q "{INSTALL_DIR}/go/bin"; then
echo "Configuring environment PATH variables..." 

# Append the Go path to the user's .bashrc profile

echo "export PATH=$PATH:

INSTALLDIR/go/bin">>"cap I cap N cap S cap T cap A cap L cap L sub cap D cap I cap R / g o / b i n " is greater than is greater than "
𝐼𝑁𝑆𝑇𝐴𝐿𝐿𝐷𝐼𝑅/𝑔𝑜/𝑏𝑖𝑛">>"
HOME/.bashrc"
echo "Please run 'source ~/.bashrc' or restart your terminal to complete the setup."

fi 

echo "Go installation completed successfully!"
"${INSTALL_DIR}/go/bin/go" version
