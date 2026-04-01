#!/usr/bin/env bash

set -euo pipefail

log_info() {
  echo "[INFO] $*"
}

log_warn() {
  echo "[WARN] $*"
}

log_error() {
  echo "[ERROR] $*" >&2
}

group_start() {
  echo "::group::$*"
}

group_end() {
  echo "::endgroup::"
}

require_file() {
  local path="$1"
  [[ -f "$path" ]] || {
    log_error "Required file not found: $path"
    exit 1
  }
}

require_dir() {
  local path="$1"
  [[ -d "$path" ]] || {
    log_error "Required directory not found: $path"
    exit 1
  }
}

append_env() {
  local key="$1"
  local value="$2"
  echo "${key}=${value}" >> "$GITHUB_ENV"
}

append_output() {
  local key="$1"
  local value="$2"
  echo "${key}=${value}" >> "$GITHUB_OUTPUT"
}

run_if_exists() {
  local path="$1"
  if [[ -f "$path" ]]; then
    chmod +x "$path"
    log_info "Run hook: $path"
    bash "$path"
  else
    log_info "Skip missing hook: $path"
  fi
}

copy_file_if_exists() {
  local src="$1"
  local dst="$2"
  if [[ -f "$src" ]]; then
    log_info "Copy file: $src -> $dst"
    mkdir -p "$(dirname "$dst")"
    cp -f "$src" "$dst"
  else
    log_info "Skip missing file: $src"
  fi
}

copy_dir_if_exists() {
  local src="$1"
  local dst="$2"
  if [[ -d "$src" ]]; then
    log_info "Copy dir: $src -> $dst"
    rm -rf "$dst"
    mkdir -p "$(dirname "$dst")"
    cp -a "$src" "$dst"
  else
    log_info "Skip missing dir: $src"
  fi
}

timestamp_compact() {
  date +"%Y%m%d%H%M"
}

timestamp_tag() {
  date +"%Y%m%d_%H%M%S"
}
