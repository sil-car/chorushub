#!/usr/bin/env bash

scripts_dir="$(dirname "$0")"
source "${scripts_dir}/build--set-env.sh"

# Ensure starting in repo root.
if [[ $PWD != "$REPO_DIR" ]]; then
    echo "Error: $0 must be run from the root of the repo."
    exit 1
fi

# Ensure that venv is activated.
if [[ -z $VIRTUAL_ENV ]]; then
    echo "Error: virtual env not activated."
    exit 1
fi

# Ensure that build files are present.
if [[ ! -d "$PRIME_DIR" || -z $(find "$PRIME_DIR" -type f) ]]; then
    echo "Prime directory doesn't exist or has no files: $PRIME_DIR"
    exit 1
fi

# Install app locally to create executable script.
pip install .
pyinstaller --clean chorushub.spec
