#!/bin/bash

# Exit immediately if any command fails
set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# install python 3.12 if not installed
chmod +x "$SCRIPT_DIR/install_python12.sh"
"$SCRIPT_DIR/install_python12.sh"

# Define the path to your symlink
SYMLINK_PATH="$HOME/workspace/software-scanning/scancode"

echo "Checking symbolic link: ${SYMLINK_PATH}"

# 1. Check if the symlink exists. If not, log it and pass cleanly.
if [ ! -L "$SYMLINK_PATH" ]; then
    echo "Notice: '${SYMLINK_PATH}' does not exist or is not a symlink. Passing..."
else
    # 2. Extract the absolute path of the target directory
    TARGET_DIR=$(realpath "$SYMLINK_PATH" 2>/dev/null || readlink -f "$SYMLINK_PATH")
    echo "Resolved target directory path: ${TARGET_DIR}"

    # 3. Critical safety guard (Keep this active to prevent catastrophic root deletion)
    if [ "$TARGET_DIR" = "/" ] || [ "$TARGET_DIR" = "$HOME" ]; then
        echo "CRITICAL WARNING: Target points to a root or home directory ($TARGET_DIR)!"
        echo "Operation aborted to prevent system damage."
        exit 1
    fi

    # 4. Delete the target directory if it exists
    if [ -d "$TARGET_DIR" ]; then
        echo "Proceeding to delete target folder..."
        rm -rf "$TARGET_DIR"
        
        if [ $? -eq 0 ]; then
            echo "Successfully removed target directory: ${TARGET_DIR}"
        else
            echo "Error: Failed to delete the target directory. Check permissions."
            exit 1
        fi
    else
        echo "Notice: Target directory '${TARGET_DIR}' does not exist. Skipping folder deletion..."
    fi

    # 5. Remove the symbolic link file itself (using -f to ensure it passes cleanly)
    rm -f "$SYMLINK_PATH"
    echo "Removed the symbolic link file: ${SYMLINK_PATH}"
fi

echo "Cleanup check completed successfully."

# 6. Download and install the specific version of scancode toolkit
#!/bin/bash

# 6.1. Define variables
TARGET_DIR="$HOME/workspace/software-scanning"
DOWNLOAD_URL="https://github.com/aboutcode-org/scancode-toolkit/releases/download/v32.3.3/scancode-toolkit-v32.3.3_py3.12-linux.tar.gz"
ARCHIVE_NAME="scancode-toolkit-v32.3.3_py3.12-linux.tar.gz"

echo "=== Starting ScanCode Toolkit Installation ==="

# 6.2. Update system package index and install required dependencies
echo "Installing system dependencies via apt..."
sudo apt update
sudo apt install -y bzip2 xz-utils zlib1g libxml2-dev libxslt1-dev libpopt0 wget

# 6.3. Create the target installation directory structure
echo "Preparing workspace directory at: ${TARGET_DIR}"
mkdir -p "$TARGET_DIR"

# 6.4. Navigate to the target directory
cd "$TARGET_DIR"

# 6.5. Download the specific ScanCode archive
echo "Downloading ScanCode Toolkit release archive..."
wget -O "$ARCHIVE_NAME" "$DOWNLOAD_URL"

# 6.6. Extract the downloaded package
echo "Extracting archive contents..."
tar -xvf "$ARCHIVE_NAME"

# 6.7. Safely remove the compressed archive file
echo "Cleaning up archive file..."
rm "$ARCHIVE_NAME"

# 6.8. Post-installation setup verification
# ScanCode archives usually create a subfolder matching the release name
EXTRACTED_FOLDER="scancode-toolkit-v32.3.3"

if [ -d "$EXTRACTED_FOLDER" ]; then
    cd "$EXTRACTED_FOLDER"
    echo "Running configuration script to initialize internal environment..."
    # Configures the isolated python app environment
    ./scancode --help > /dev/null
    
    echo "======================================================="
    echo " SUCCESS: ScanCode Toolkit installed successfully!"
    echo " Executable location: $(pwd)/scancode"
    echo "======================================================="
else
    echo "Warning: Expected extraction directory '${EXTRACTED_FOLDER}' not found."
    echo "Please check 'ls' in ${TARGET_DIR} to confirm folder name."
fi

#7 Recreate the symbolic link
# 7.1. Define paths (using absolute references for reliability)
TARGET_LINK="$HOME/workspace/software-scanning/scancode"
REAL_BINARY="$HOME/workspace/software-scanning/scancode-toolkit-v32.3.3"

# 7.2. Safely remove old/broken link if it exists
if [ -L "$TARGET_LINK" ] || [ -e "$TARGET_LINK" ]; then
    echo "Removing existing symlink or file at ${TARGET_LINK}..."
    rm -f "$TARGET_LINK"
fi

# 7.3. Create the new symbolic link
echo "Creating new symbolic link pointing to the updated scancode..."
ln -s "$REAL_BINARY" "$TARGET_LINK"

# 7.4. Verify the link is working
if [ -L "$TARGET_LINK" ]; then
    echo "SUCCESS: Symbolic link recreated at: ${TARGET_LINK}"
    echo "Points to: $(readlink -f "$TARGET_LINK")"
else
    echo "ERROR: Failed to create symbolic link."
    exit 1
fi

# 8 verfy the symbolic link execution
"$TARGET_LINK"/scancode -V


