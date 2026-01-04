#!/bin/sh
set -e

echo "=== Xcode Cloud Post Clone Script ==="

cd "$CI_PRIMARY_REPOSITORY_PATH"

echo "Installing mise..."
curl https://mise.run | sh
export PATH="$HOME/.local/bin:$PATH"

echo "Installing tuist via mise..."
mise install tuist
eval "$(mise activate bash)"

echo "Running tuist install..."
tuist install

echo "Running tuist generate..."
tuist generate

echo "=== Post Clone Complete ==="
