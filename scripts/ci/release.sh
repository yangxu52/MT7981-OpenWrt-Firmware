#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=scripts/ci/lib.sh
source "${SCRIPT_DIR}/lib.sh"

prepare_release_metadata() {
  : "${PROFILE_ID:?PROFILE_ID is required}"
  : "${PROFILE_NAME:?PROFILE_NAME is required}"
  : "${FILE_DATE:?FILE_DATE is required}"

  group_start "Release: Prepare Metadata"

  local release_tag="${PROFILE_ID}-$(timestamp_tag)"
  local release_name="${PROFILE_NAME} ${FILE_DATE}"
  local release_body="${GITHUB_WORKSPACE}/release.txt"

  {
    echo "Profile: ${PROFILE_NAME}"
    echo "Profile ID: ${PROFILE_ID}"
    echo "Branch: ${REPO_BRANCH:-unknown}"
    echo "Build Time: ${FILE_DATE}"
    echo "Commit: ${GITHUB_SHA}"
    echo "Run: ${GITHUB_SERVER_URL}/${GITHUB_REPOSITORY}/actions/runs/${GITHUB_RUN_ID}"
  } > "$release_body"

  append_env "RELEASE_TAG" "$release_tag"
  append_env "RELEASE_NAME" "$release_name"
  append_env "RELEASE_BODY" "$release_body"

  group_end
}

case "${1:-}" in
  prepare-release-metadata)
    prepare_release_metadata
    ;;
  *)
    log_error "Unknown command: ${1:-}"
    exit 1
    ;;
esac
