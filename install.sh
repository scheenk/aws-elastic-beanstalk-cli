#!/bin/bash
set -e

REPO="scheenk/aws-elastic-beanstalk-cli"
INSTALL_DIR="/usr/local/lib/eb-cli"
BIN_DIR="/usr/local/bin"

OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)
case "$ARCH" in aarch64|arm64) ARCH="arm64" ;; x86_64) ARCH="x86_64" ;; esac

# macOS reports "darwin"
case "$OS" in darwin) OS="macos" ;; esac

VERSION=${1:-$(curl -sSf "https://api.github.com/repos/${REPO}/releases/latest" | grep '"tag_name"' | cut -d'"' -f4)}
BINARY="eb-${OS}-${ARCH}.tar.gz"
BASE_URL="https://github.com/${REPO}/releases/download/${VERSION}"

echo "Installing EB CLI ${VERSION} for ${OS}/${ARCH}..."
curl -sSfL -o /tmp/eb-cli.tar.gz "$BASE_URL/$BINARY"
curl -sSfL -o /tmp/checksums.txt "$BASE_URL/checksums.txt"

# Verify checksum
EXPECTED=$(grep "$BINARY" /tmp/checksums.txt | awk '{print $1}')
if [ -z "$EXPECTED" ]; then
  echo "Warning: no checksum found for $BINARY, skipping verification"
else
  if command -v sha256sum &>/dev/null; then
    ACTUAL=$(sha256sum /tmp/eb-cli.tar.gz | awk '{print $1}')
  else
    ACTUAL=$(shasum -a 256 /tmp/eb-cli.tar.gz | awk '{print $1}')
  fi
  if [ "$EXPECTED" != "$ACTUAL" ]; then
    echo "Checksum verification failed!"
    echo "  Expected: $EXPECTED"
    echo "  Actual:   $ACTUAL"
    rm -f /tmp/eb-cli.tar.gz /tmp/checksums.txt
    exit 1
  fi
  echo "Checksum verified."
fi

sudo rm -rf "$INSTALL_DIR"
sudo mkdir -p "$INSTALL_DIR"
sudo tar xzf /tmp/eb-cli.tar.gz -C "$INSTALL_DIR"
sudo ln -sf "$INSTALL_DIR/eb/eb" "$BIN_DIR/eb"
rm -f /tmp/eb-cli.tar.gz /tmp/checksums.txt
echo "EB CLI ${VERSION} installed to ${BIN_DIR}/eb"
