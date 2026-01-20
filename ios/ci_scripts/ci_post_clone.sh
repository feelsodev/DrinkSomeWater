#!/bin/sh
set -e

echo "=== Xcode Cloud Post Clone Script ==="

cd "$CI_PRIMARY_REPOSITORY_PATH/ios"

echo "Installing mise..."
curl https://mise.jdx.dev/install.sh | sh
export PATH="$HOME/.local/bin:$PATH"

echo "Verifying mise installation..."
~/.local/bin/mise --version

echo "Installing tools from .mise.toml..."
~/.local/bin/mise install

echo "Verifying mise setup..."
~/.local/bin/mise doctor || echo "mise doctor warnings (non-blocking)"

echo "Running tuist install..."
~/.local/bin/mise x -- tuist install

echo "Running tuist generate..."
~/.local/bin/mise x -- tuist generate --no-open

echo "=== Post Clone Complete ==="
