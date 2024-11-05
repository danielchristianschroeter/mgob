#!/bin/sh

set -e

# Function to determine architecture suffix
get_arch_suffix() {
  case "$(uname -m)" in
    aarch64) echo "arm64" ;;
    x86_64) echo "amd64" ;;
    *) echo "amd64" ;;  # Default to amd64 if architecture is not recognized
  esac
}

# Function to get the correct architecture suffix for Google Cloud SDK
get_gcloud_arch_suffix() {
  case "$(uname -m)" in
    aarch64) echo "arm" ;;
    x86_64) echo "x86_64" ;;
    *) echo "x86_64" ;;  # Default to x86_64 if architecture is not recognized
  esac
}

ARCH_SUFFIX=$(get_arch_suffix)
GCLOUD_ARCH_SUFFIX=$(get_gcloud_arch_suffix)

# Install common packages
apk add --no-cache ca-certificates tzdata bash curl krb5-dev

# Install GnuPG conditionally
if [ "${MGOB_EN_GPG}" = "true" ]; then
  apk add --no-cache gnupg="${GNUPG_VERSION}"
fi

cd /tmp

# Ensure Python and pip are installed before running pip-specific commands
apk add --no-cache python3 py3-pip

# Install MinIO client if enabled
install_minio() {
  echo "Installing MinIO Client..."
  curl -LO "https://dl.minio.io/client/mc/release/linux-${ARCH_SUFFIX}/mc"
  install -m 755 mc /usr/bin/
  rm mc
}

# Install RClone if enabled
install_rclone() {
  echo "Installing RClone..."
  curl -LO "https://downloads.rclone.org/rclone-current-linux-${ARCH_SUFFIX}.zip"
  unzip "rclone-current-linux-${ARCH_SUFFIX}.zip"
  RCLONE_DIR=$(find . -maxdepth 1 -type d -name "rclone-*")
  install -m 755 "${RCLONE_DIR}/rclone" /usr/bin/
  rm -rf "rclone-current-linux-${ARCH_SUFFIX}.zip" "${RCLONE_DIR}"
}

# Install Google Cloud SDK if enabled
install_gcloud() {
  echo "Installing Google Cloud SDK..."
  apk add --no-cache python3 py3-pip libc6-compat openssh-client git
  pip3 install --no-cache-dir --upgrade pip
  pip3 install --no-cache-dir wheel crcmod

  curl -LO "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${GOOGLE_CLOUD_SDK_VERSION}-linux-${GCLOUD_ARCH_SUFFIX}.tar.gz"
  tar -xzf "google-cloud-sdk-${GOOGLE_CLOUD_SDK_VERSION}-linux-${GCLOUD_ARCH_SUFFIX}.tar.gz" -C /
  rm "google-cloud-sdk-${GOOGLE_CLOUD_SDK_VERSION}-linux-${GCLOUD_ARCH_SUFFIX}.tar.gz"
  
  ln -s /lib /lib64 || true  # Some tools expect /lib64

  # Configure gcloud
  /google-cloud-sdk/bin/gcloud config set core/disable_usage_reporting true
  /google-cloud-sdk/bin/gcloud config set component_manager/disable_update_check true
  /google-cloud-sdk/bin/gcloud config set metrics/environment github_docker_image
  /google-cloud-sdk/bin/gcloud --version
}

# Install Azure CLI and AWS CLI if enabled
install_cli_tools() {
  echo "Installing Azure CLI and/or AWS CLI..."

  # Install build dependencies
  apk add --no-cache --virtual .build-deps gcc libffi-dev musl-dev openssl-dev python3-dev make

  # Install virtualenv
  pip3 install --no-cache-dir virtualenv

  # Create a virtual environment for CLI tools
  VENV_DIR="/opt/mgob-venv"
  virtualenv "${VENV_DIR}"
  . "${VENV_DIR}/bin/activate"

  # Upgrade pip inside the virtual environment
  pip install --no-cache-dir --upgrade pip wheel

  # Install Azure CLI if enabled
  if [ "${MGOB_EN_AZURE}" = "true" ]; then
    echo "Installing Azure CLI..."
    pip install --no-cache-dir "azure-cli==${AZURE_CLI_VERSION}"
    # Symlink the az binary
    ln -s "${VENV_DIR}/bin/az" /usr/bin/az
  fi

  # Install AWS CLI if enabled
  if [ "${MGOB_EN_AWS_CLI}" = "true" ]; then
    echo "Installing AWS CLI..."
    pip install --no-cache-dir "awscli==${AWS_CLI_VERSION}"
    # Symlink the aws binary
    ln -s "${VENV_DIR}/bin/aws" /usr/bin/aws
  fi

  # Deactivate and remove build dependencies
  deactivate
  apk del .build-deps
}

# Execute installations based on environment variables
[ "${MGOB_EN_MINIO}" = "true" ] && install_minio
[ "${MGOB_EN_RCLONE}" = "true" ] && install_rclone
[ "${MGOB_EN_GCLOUD}" = "true" ] && install_gcloud
[ "${MGOB_EN_AZURE}" = "true" ] || [ "${MGOB_EN_AWS_CLI}" = "true" ] && install_cli_tools

# Clean up
apk cache clean
rm -rf /tmp/*