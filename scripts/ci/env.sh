#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/../.." && pwd)"

# shellcheck source=scripts/ci/lib.sh
source "${SCRIPT_DIR}/lib.sh"

load_profile() {
  local profile_id="$1"
  local profile_dir="${REPO_ROOT}/profiles/${profile_id}"
  local profile_env="${profile_dir}/profile.env"
  local profile_config="${profile_dir}/.config"

  require_dir "$profile_dir"
  require_file "$profile_env"
  require_file "$profile_config"

  # shellcheck disable=SC1090
  source "$profile_env"

  : "${PROFILE_NAME:?PROFILE_NAME is required}"
  : "${TARGET:?TARGET is required}"
  : "${SUBTARGET:?SUBTARGET is required}"

  local device="${DEVICE:-$profile_id}"

  append_env "PROFILE_DIR" "$profile_dir"
  append_env "PROFILE_ID" "$profile_id"
  append_env "PROFILE_NAME" "${PROFILE_NAME}"
  append_env "DEVICE" "${device}"
  append_env "TARGET" "${TARGET}"
  append_env "SUBTARGET" "${SUBTARGET}"
  append_env "MODIFY_HOSTNAME" "${MODIFY_HOSTNAME:-}"
  append_env "MODIFY_IP" "${MODIFY_IP:-}"
  append_env "MODIFY_ADDR_OFFSET" "${MODIFY_ADDR_OFFSET:-}"
  append_env "MODIFY_WIFI_2G_SSID" "${MODIFY_WIFI_2G_SSID:-}"
  append_env "MODIFY_WIFI_5G_SSID" "${MODIFY_WIFI_5G_SSID:-}"

  log_info "Loaded profile: ${profile_id} (${PROFILE_NAME})"
}

case "${1:-}" in
  load-profile)
    load_profile "${2:?profile id is required}"
    ;;
  *)
    log_error "Unknown command: ${1:-}"
    exit 1
    ;;
esac
