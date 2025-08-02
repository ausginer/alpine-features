#!/usr/bin/env sh
set -eu

parse_version() {
  local versions_json="$1"
  local version="$2"

  if [ "$version" = "lts" ]; then
    # Find first LTS version
    echo "$versions_json" | jq -r '.[] | select(.lts != false) | .version' | head -n1 | sed 's/^v//'
  elif [ "$version" = "latest" ]; then
    # First entry is the latest version
    echo "$versions_json" | jq -r '.[0].version' | sed 's/^v//'
  else
    # Find version that starts with input
    echo "$versions_json" | jq -r --arg v "$version" '.[] | select(.version | test("^v"+$v)) | .version' | head -n1 | sed 's/^v//'
  fi
}

# --- Arguments ---
VERSION="$1"

# Download index.json
VERSION_JSON=$(wget -qO- https://nodejs.org/dist/index.json)
FULL_VERSION="$(parse_version "$VERSION_JSON" "$VERSION")"

if [ -z "$FULL_VERSION" ]; then
  echo "Version $VERSION not found" >&2
  exit 1
fi

echo "$FULL_VERSION"