#!/usr/bin/env bash
set -euo pipefail

PROFILE_DIR="${1:?Usage: $0 <profile-dir> <git-repo-url>}"
REPO_URL="${2:?Usage: $0 <profile-dir> <git-repo-url>}"

PROFILE_DIR="$(realpath "$PROFILE_DIR")"
TMP_DIR="$(mktemp -d "/tmp/hermes-git.XXXXXX")"

trap 'rm -rf "$TMP_DIR"' EXIT

echo "Cloning upstream into $TMP_DIR..."
git clone "$REPO_URL" "$TMP_DIR/repo"

echo "Installing Git metadata into profile..."
cp -a "$TMP_DIR/repo/.git" "$PROFILE_DIR/.git"

cd "$PROFILE_DIR"

echo
echo "Git status:"
git status

echo
echo "Done."
