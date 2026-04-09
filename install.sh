#!/bin/bash
set -e

REPO="scheenk/aws-elastic-beanstalk-cli"
INSTALL_DIR="/usr/local/bin"

OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)
case "$ARCH" in aarch64|arm64) ARCH="arm64" ;; x86_64) ARCH="x86_64" ;; esac

# macOS reports "darwin"
case "$OS" in darwin) OS="macos" ;; esac

VERSION=${1:-$(curl -sSf "https://api.github.com/repos/${REPO}/releases/latest" | grep '"tag_name"' | cut -d'"' -f4)}

URL="https://github.com/${REPO}/releases/download/${VERSION}/eb-${OS}-${ARCH}"

echo "Installing EB CLI ${VERSION} for ${OS}/${ARCH}..."
curl -sSfL -o /tmp/eb "$URL"
chmod +x /tmp/eb
sudo mv /tmp/eb "${INSTALL_DIR}/eb"
echo "EB CLI ${VERSION} installed to ${INSTALL_DIR}/eb"
