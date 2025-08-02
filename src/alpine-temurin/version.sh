#!/usr/bin/env sh
set -eu

# --- Arguments ---
VERSION="$1"
ARCH="$2"

parse_version() {
  local version="$1"
  local parts
  parts=$(echo "$version" | awk -F'[.+]' '{print $1, $2, $3, $4}')
  set -- $parts
  echo "${1:-}" "${2:-}" "${3:-}" "${4:-}"
}

load_available_releases() {
  wget --header='accept: application/json' -qO- 'https://api.adoptium.net/v3/info/available_releases'
}

load_versions() {
  local feature_version="$1"
  local arch="$2"
  local type="$3"
  wget --header='accept: application/json' -qO- "https://api.adoptium.net/v3/assets/feature_releases/${feature_version}/${type}?architecture=${arch}&os=alpine-linux&project=jdk&sort_order=DESC"
}

parse_versions_json() {
  local versions_json="$1"
  local major="$2"
  local minor="$3"
  local security="$4"
  local build="$5"
  echo "$versions_json" | jq -r --argjson major "$major" --argjson minor "$minor" --argjson security "$security" --argjson build "$build" '
    .[] | select(
      (.version_data.major == $major) and
      ( ($minor == null or .version_data.minor == $minor) ) and
      ( ($security == null or .version_data.security == $security) ) and
      ( ($build == null or .version_data.build == $build) )
    ) | .binaries[] | select(.image_type == "jdk") | .package
    | [.checksum, .link, .signature_link] | @tsv
  ' | head -n1
}

RELEASES_JSON="$(load_available_releases)"

DEV="$(echo "$RELEASES_JSON" | jq -r '.most_recent_feature_version')"
LATEST="$(echo "$RELEASES_JSON" | jq -r '.most_recent_feature_release')"
LTS="$(echo "$RELEASES_JSON" | jq -r '.most_recent_lts')"
AVAILABLE_RELEASES="$(echo "$RELEASES_JSON" | jq -r '.available_releases | join(" ")')"

if [ "$VERSION" = "dev" ]; then
  VERSIONS_JSON="$(load_versions "$DEV" "$ARCH" "ea")"
  set -- $(parse_version "$DEV")
  MAJOR="${1:-null}"; MINOR="${2:-null}"; SECURITY="${3:-null}"; BUILD="${4:-null}"
  RESULT_LINE="$(parse_versions_json "$VERSIONS_JSON" "$MAJOR" "$MINOR" "$SECURITY" "$BUILD")"
elif [ "$VERSION" = "latest" ]; then
  VERSIONS_JSON="$(load_versions "$LATEST" "$ARCH" "ga")"
  set -- $(parse_version "$LATEST")
  MAJOR="${1:-null}"; MINOR="${2:-null}"; SECURITY="${3:-null}"; BUILD="${4:-null}"
  RESULT_LINE="$(parse_versions_json "$VERSIONS_JSON" "$MAJOR" "$MINOR" "$SECURITY" "$BUILD")"
elif [ "$VERSION" = "lts" ]; then
  VERSIONS_JSON="$(load_versions "$LTS" "$ARCH" "ga")"
  set -- $(parse_version "$LTS")
  MAJOR="${1:-null}"; MINOR="${2:-null}"; SECURITY="${3:-null}"; BUILD="${4:-null}"
  RESULT_LINE="$(parse_versions_json "$VERSIONS_JSON" "$MAJOR" "$MINOR" "$SECURITY" "$BUILD")"
else
  set -- $(parse_version "$VERSION")
  MAJOR="${1:-null}"; MINOR="${2:-null}"; SECURITY="${3:-null}"; BUILD="${4:-null}"
  if ! echo "$AVAILABLE_RELEASES" | grep -wq "$MAJOR"; then
    echo "Unsupported version: $VERSION. Available versions: $AVAILABLE_RELEASES" >&2
    exit 1
  fi
  VERSIONS_JSON="$(load_versions "$MAJOR" "$ARCH" "ga")"
  RESULT_LINE="$(parse_versions_json "$VERSIONS_JSON" "$MAJOR" "$MINOR" "$SECURITY" "$BUILD")"
fi

if [ -z "$RESULT_LINE" ]; then
  echo "No matching version found for Temurin $VERSION ($ARCH)" >&2
  exit 1
fi

CHECKSUM="$(echo "$RESULT_LINE" | cut -f1)"
BINARY_LINK="$(echo "$RESULT_LINE" | cut -f2)"
SIGNATURE_LINK="$(echo "$RESULT_LINE" | cut -f3)"

echo "$CHECKSUM" "$BINARY_LINK" "$SIGNATURE_LINK"
