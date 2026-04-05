#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/../.." && pwd)"

# shellcheck source=scripts/ci/lib.sh
source "${SCRIPT_DIR}/lib.sh"

OPENWRT_ROOT="${GITHUB_WORKSPACE}/openwrt"
CCACHE_DIR="${OPENWRT_ROOT}/.ccache"

COMPILE_DEPENDS=(
  ack antlr3 asciidoc autoconf automake autopoint binutils bison build-essential
  bzip2 ccache cmake cpio curl device-tree-compiler fastjar flex gawk gettext
  gcc-multilib g++-multilib git gperf haveged help2man intltool libc6-dev-i386
  libelf-dev libfuse-dev libglib2.0-dev libgmp3-dev libltdl-dev libmpc-dev
  libmpfr-dev libncurses-dev libpython3-dev libreadline-dev
  libssl-dev libtool lrzsz genisoimage msmtp ninja-build 7zip patch
  pkgconf python3 python3-pyelftools python3-setuptools qemu-utils
  rsync scons squashfs-tools subversion swig texinfo uglifyjs upx-ucl unzip vim
  wget xmlto xxd zlib1g-dev
)

initialize_environment() {
  group_start "Environment: Initialize"
  
  find /etc/apt/sources.list.d -mindepth 1
  sudo find /etc/apt/sources.list.d -mindepth 1 ! -name 'ubuntu.sources' -exec rm -rf {} +
  sudo -E apt-get -qq update
  sudo -E apt-get -qq full-upgrade -y
  sudo -E apt-get -qq install -y "${COMPILE_DEPENDS[@]}"
  sudo -E apt-get -qq --purge autoremove
  sudo -E apt-get -qq autoclean

  echo "${TZ:-Asia/Shanghai}" | sudo tee /etc/timezone >/dev/null
  sudo timedatectl set-timezone "${TZ:-Asia/Shanghai}"

  mkdir -p "$OPENWRT_ROOT"

  export CCACHE_DIR="$CCACHE_DIR"
  export PATH="/usr/lib/ccache:$PATH"

  echo "CCACHE_DIR=$CCACHE_DIR" >> "$GITHUB_ENV"
  echo "/usr/lib/ccache" >> "$GITHUB_PATH"

  group_end
}

prepare_source() {
  : "${REPO_URL:?REPO_URL is required}"
  : "${REPO_BRANCH:?REPO_BRANCH is required}"

  group_start "Source: Prepare"

  if [[ -d "$OPENWRT_ROOT/.git" ]]; then
    log_info "Source already exists: $OPENWRT_ROOT"
  elif [[ -d "$OPENWRT_ROOT" ]] && [[ -n "$(ls -A "$OPENWRT_ROOT" 2>/dev/null)" ]]; then
    log_error "OpenWrt root exists but is not a git repository: $OPENWRT_ROOT"
    exit 1
  else
    rm -rf "$OPENWRT_ROOT"
    git clone -b "$REPO_BRANCH" --single-branch "$REPO_URL" "$OPENWRT_ROOT"
  fi

  group_end
}

apply_source_customization() {
  : "${PROFILE_DIR:?PROFILE_DIR is required}"

  group_start "Source: Apply Customization"

  local feeds_file="${PROFILE_DIR}/feeds.conf.default"
  local common_hooks_dir="${REPO_ROOT}/profiles/common/scripts"
  local profile_hooks_dir="${PROFILE_DIR}/scripts"

  copy_file_if_exists "$feeds_file" "${OPENWRT_ROOT}/feeds.conf.default"

  cd "$OPENWRT_ROOT"

  run_if_exists "${common_hooks_dir}/pre-feeds.sh"
  run_if_exists "${profile_hooks_dir}/pre-feeds.sh"

  ./scripts/feeds update -a

  run_if_exists "${common_hooks_dir}/post-feeds-update.sh"
  run_if_exists "${profile_hooks_dir}/post-feeds-update.sh"

  ./scripts/feeds install -a

  run_if_exists "${common_hooks_dir}/post-feeds-install.sh"
  run_if_exists "${profile_hooks_dir}/post-feeds-install.sh"

  copy_dir_if_exists "${PROFILE_DIR}/files" "${OPENWRT_ROOT}/files"
  copy_file_if_exists "${PROFILE_DIR}/.config" "${OPENWRT_ROOT}/.config"

  group_end
}

download_sources() {
  group_start "Build: Download Sources"

  cd "$OPENWRT_ROOT"
  make defconfig
  make download -j"$(nproc)"

  find dl -size -1024c -exec ls -l {} \; || true
  find dl -size -1024c -exec rm -f {} \; || true

  group_end
}

set_build_metadata() {
  local file_date
  file_date="$(timestamp_compact)"

  append_env "FILE_DATE" "${file_date}"
}

build_firmware() {
  group_start "Build: Firmware"

  cd "$OPENWRT_ROOT"
  log_info "Run parallel build with $(nproc) jobs"

  ccache -s || true
  make -j"$(nproc)"
  ccache -s || true

  set_build_metadata
  df -hT

  group_end
}

build_firmware_verbose() {
  group_start "Build: Firmware (Verbose Fallback)"

  cd "$OPENWRT_ROOT"
  log_warn "Parallel build failed, retry with single job and verbose logs"

  ccache -s || true
  make -j1 V=s
  ccache -s || true

  set_build_metadata

  group_end
}

case "${1:-}" in
  initialize-environment)
    initialize_environment
    ;;
  prepare-source)
    prepare_source
    ;;
  apply-source-customization)
    apply_source_customization
    ;;
  download-sources)
    download_sources
    ;;
  build-firmware)
    build_firmware
    ;;
  build-firmware-verbose)
    build_firmware_verbose
    ;;
  *)
    log_error "Unknown command: ${1:-}"
    exit 1
    ;;
esac
