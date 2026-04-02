#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/ci/lib.sh
source "${SCRIPT_DIR}/lib.sh"

OPENWRT_ROOT="${GITHUB_WORKSPACE}/openwrt"

resolve_firmware_dir() {
  local dir=""

  if [[ -n "${TARGET_SUBDIR_HINT:-}" && -d "${OPENWRT_ROOT}/bin/targets/${TARGET_SUBDIR_HINT}" ]]; then
    dir="${OPENWRT_ROOT}/bin/targets/${TARGET_SUBDIR_HINT}"
  else
    dir="$(find "${OPENWRT_ROOT}/bin/targets" -mindepth 2 -maxdepth 2 -type d | head -n1)"
  fi

  [[ -n "$dir" && -d "$dir" ]] || {
    log_error "Firmware directory not found"
    exit 1
  }

  echo "$dir"
}

collect() {
  : "${PROFILE_ID:?PROFILE_ID is required}"
  : "${FILE_DATE:?FILE_DATE is required}"

  group_start "Collect firmware artifacts"

  local firmware_dir
  firmware_dir="$(resolve_firmware_dir)"

  cd "$firmware_dir"

  rm -rf packages

  find . -maxdepth 1 -type f \
    ! -name "*.bin" \
    ! -name "*.img" \
    ! -name "*.img.gz" \
    ! -name "*.itb" \
    ! -name "*.tar" \
    ! -name "*.manifest" \
    ! -name "*.buildinfo" \
    ! -name "sha256sums*" \
    -delete

  local artifact_name="openwrt-${PROFILE_ID}-${FILE_DATE}"

  append_env "FIRMWARE_DIR" "$firmware_dir"
  append_env "ARTIFACT_NAME" "$artifact_name"

  log_info "Firmware dir: $firmware_dir"
  log_info "Artifact name: $artifact_name"

  group_end
}

collect