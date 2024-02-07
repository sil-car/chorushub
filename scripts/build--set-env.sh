#!/usr/bin/env bash

scripts_dir="$(dirname "$0")"
REPO_DIR="$(dirname "$scripts_dir")"
if [[ ! -d "${REPO_DIR}/.git" ]]; then
  echo "Error: Not repo base dir: $REPO_DIR"
  exit 1
fi
export REPO_DIR
export BUILD_DIR="${REPO_DIR}/build"
export PKGS_DIR="${BUILD_DIR}/pkgs"
export STAGE_DIR="${BUILD_DIR}/stage"
export PRIME_DIR="${BUILD_DIR}/prime"
