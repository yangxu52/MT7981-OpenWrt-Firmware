#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=scripts/ci/lib.sh
source "${SCRIPT_DIR}/lib.sh"

OPENWRT_ROOT="${GITHUB_WORKSPACE}/openwrt"

compute_cache_keys() {
  : "${PROFILE_DIR:?PROFILE_DIR is required}"
  : "${PROFILE_ID:?PROFILE_ID is required}"
  : "${TARGET:?TARGET is required}"
  : "${SUBTARGET:?SUBTARGET is required}"

  local device="${DEVICE:-$PROFILE_ID}"
  local tool_head
  local toolchain_head
  local lang_head
  local ccache_hash

  tool_head="$(git -C "$OPENWRT_ROOT" rev-parse "HEAD:tools")"
  toolchain_head="$(git -C "$OPENWRT_ROOT" rev-parse "HEAD:toolchain")"

  require_file "${PROFILE_DIR}/.config"
  require_dir "${OPENWRT_ROOT}/feeds/packages/lang"
  ccache_hash="$(sha256sum "${PROFILE_DIR}/.config" | cut -d' ' -f1)"
  lang_head="$(
    cd "${OPENWRT_ROOT}/feeds/packages/lang"
    find . \
      \( -path './.git' -o -path './.git/*' \) -prune -o \
      \( -type f -o -type l \) -print0 \
      | LC_ALL=C sort -z \
      | while IFS= read -r -d '' path; do
          if [[ -L "$path" ]]; then
            printf 'L %s %s\n' "$path" "$(readlink "$path")"
          else
            printf 'F %s %s\n' "$path" "$(sha256sum "$path" | cut -d' ' -f1)"
          fi
        done \
      | sha256sum | cut -d' ' -f1
  )"

  append_env "TOOL_HEAD" "$tool_head"
  append_env "TOOLCHAIN_HEAD" "$toolchain_head"
  append_env "LANG_HEAD" "$lang_head"
  append_env "CCACHE_HASH" "$ccache_hash"
}

case "${1:-}" in
  compute-cache-keys)
    compute_cache_keys
    ;;
  *)
    log_error "Unknown command: ${1:-}"
    exit 1
    ;;
esac
