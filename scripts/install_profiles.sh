#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

PROFILE_DIR="${HERMES_HOME}/profiles"

source "$SCRIPT_DIR/profiles.conf"

# Configure Git for the hermes user
git config --global credential.helper \
  '!f() {
    echo username=x-access-token
    echo password=$GIT_TOKEN
  }; f'

for name in "${!PROFILE_URL[@]}"; do
    url="${PROFILE_URL[$name]}"

    if [[ -d "$PROFILE_DIR/$name" ]]; then
        echo "Profile '$name' already exists, skipping"
        continue
    fi

    echo "Installing profile: $name"
    # Remove once this is fixed: https://github.com/NousResearch/hermes-agent/issues/54174
    hermes profile create "$name"
    hermes profile install "$url" -y --alias --force

    if [[ " ${SETUP_PROFILES[*]} " == *" $name "* ]]; then
        echo "Running setup for: $name"
        "$SCRIPT_DIR/copy_git_dir.sh" "$PROFILE_DIR/$name" "$url"
    fi
done

hermes profile use $DEFAULT_PROFILE
hermes gateway start
hermes -p default gateway stop
