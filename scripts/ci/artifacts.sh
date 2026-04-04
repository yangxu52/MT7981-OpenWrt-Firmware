#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/ci/lib.sh
source "${SCRIPT_DIR}/lib.sh"

OPENWRT_ROOT="${GITHUB_WORKSPACE}/openwrt"

resolve_firmware_dir() {
  : "${TARGET:?TARGET is required}"
  : "${SUBTARGET:?SUBTARGET is required}"

  local dir="${OPENWRT_ROOT}/bin/targets/${TARGET}/${SUBTARGET}"

  if [[ ! -d "$dir" ]]; then
    dir="$(find "${OPENWRT_ROOT}/bin/targets" -mindepth 2 -maxdepth 2 -type d | head -n1)"
  fi

  [[ -n "$dir" && -d "$dir" ]] || {
    log_error "Firmware directory not found"
    exit 1
  }

  echo "$dir"
}

collect_firmware() {
  : "${PROFILE_ID:?PROFILE_ID is required}"
  : "${FILE_DATE:?FILE_DATE is required}"

  group_start "Artifacts: Collect Firmware"

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

case "${1:-}" in
  collect-firmware)
    collect_firmware
    ;;
  *)
    log_error "Unknown command: ${1:-}"
    exit 1
    ;;
esac
