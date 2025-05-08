#!/bin/bash

# Initialize cpu only flag
cpu_flag=false

# Loop through the command-line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --cpu)
            cpu_flag=true
            shift # Remove the current argument from the list
            ;;
        *)
            echo "Invalid argument: $1" >&2
            exit 1
            ;;
    esac
done

# Work inside the home directory
PREV_DIR=$PWD
cd ~

# Define the ONNX Runtime version
ONNX_VERSION="1.19.2"
BASE_URL="https://github.com/microsoft/onnxruntime/releases/download/v${ONNX_VERSION}"

# Function to determine the OS
get_os_type() {
    case "$(uname -s)" in
        Linux*) echo "Linux" ;;
        Darwin*) echo "MacOS" ;;
        *) echo "Unsupported" ;;
    esac
}

# Determine the OS
OS_TYPE=$(get_os_type)

if [ "$OS_TYPE" == "Linux" ]; then
    # Check if the cpu flag was provided
    if $cpu_flag; then
        FILE_NAME="onnxruntime-linux-x64-${ONNX_VERSION}.tgz"
    else
        # GPU version (assuming CUDA-enabled GPU support)
        FILE_NAME="onnxruntime-linux-x64-gpu-${ONNX_VERSION}.tgz"
    fi
elif [ "$OS_TYPE" == "MacOS" ]; then
    FILE_NAME="onnxruntime-osx-arm64-${ONNX_VERSION}.tgz"
else
    echo "Unsupported operating system. This script supports Linux and MacOS only."
    exit 1
fi

# Download the appropriate file
DOWNLOAD_URL="${BASE_URL}/${FILE_NAME}"
echo "Downloading ONNX Runtime version ${ONNX_VERSION} for ${OS_TYPE}..."
curl -L -o "${FILE_NAME}" "${DOWNLOAD_URL}"

if [ $? -eq 0 ]; then
    echo "Download successful: ${FILE_NAME}"
else
    echo "Download failed. Please check your internet connection."
    exit 1
fi

# Extract the downloaded file
echo "Extracting ${FILE_NAME}..."
tar -xzf "${FILE_NAME}"

if [ $? -eq 0 ]; then
    echo "Extraction complete."
else
    echo "Extraction failed. Please check the downloaded file."
    exit 1
fi

# Find the extracted directory (assumes it extracts to a single top-level directory)
EXTRACTED_DIR=$(tar -tzf "${FILE_NAME}" | head -1 | cut -f1 -d"/")
if [ -d "${EXTRACTED_DIR}/lib" ]; then
    LIB_PATH="${PWD}/${EXTRACTED_DIR}/lib"

    # Detect user's shell and configure the appropriate profile file
    if [[ "$SHELL" == *"zsh"* ]]; then
        SHELL_PROFILE="$HOME/.zshrc"
    elif [[ "$SHELL" == *"bash"* ]]; then
        SHELL_PROFILE="$HOME/.bashrc"
    elif [[ "$SHELL" == *"sh"* ]]; then
        SHELL_PROFILE="$HOME/.profile"
    else
        echo "Unrecognized shell: $SHELL. Please manually update your LD_LIBRARY_PATH in your shell's configuration file."
        exit 1
    fi

    # Add the LD_LIBRARY_PATH to the shell profile for persistence
    if [ "$OS_TYPE" == "Linux" ]; then
        # Set LD_LIBRARY_PATH
        export LD_LIBRARY_PATH="${LIB_PATH}"
        echo "LD_LIBRARY_PATH set to: ${LD_LIBRARY_PATH}"
        echo "export LD_LIBRARY_PATH=${LIB_PATH}" >> "$SHELL_PROFILE"
        echo "Persistent LD_LIBRARY_PATH setting added to $SHELL_PROFILE"
    elif [ "$OS_TYPE" == "MacOS" ]; then
        export DYLD_LIBRARY_PATH="${LIB_PATH}"
        echo "DYLD_LIBRARY_PATH set to: ${DYLD_LIBRARY_PATH}"
        echo "export DYLD_LIBRARY_PATH=${LIB_PATH}" >> "$SHELL_PROFILE"
        echo "Persistent DYLD_LIBRARY_PATH setting added to $SHELL_PROFILE"
    else
        echo "Unsupported operating system. This script supports Linux and MacOS only."
        exit 1
    fi
else
    echo "lib directory not found in extracted files."
    exit 1
fi

# Clean temporary files
rm $FILE_NAME

# Go back to original directory
cd $PREV_DIR

echo "Done! Please restart your terminal session."
