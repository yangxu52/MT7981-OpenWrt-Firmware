#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/../.." && pwd)"

# shellcheck source=scripts/ci/lib.sh
source "${SCRIPT_DIR}/lib.sh"

OPENWRT_ROOT="/workdir/openwrt"
CCACHE_DIR="/workdir/.ccache"
CARGO_HOME="/workdir/.cargo"

COMPILE_DEPENDS=(
  ack antlr3 asciidoc autoconf automake autopoint binutils bison build-essential
  bzip2 ccache cmake cpio curl device-tree-compiler fastjar flex gawk gettext
  gcc-multilib g++-multilib git gperf haveged help2man intltool libc6-dev-i386
  libelf-dev libfuse-dev libglib2.0-dev libgmp3-dev libltdl-dev libmpc-dev
  libmpfr-dev libncurses5-dev libncursesw5-dev libpython3-dev libreadline-dev
  libssl-dev libtool lrzsz mkisofs msmtp ninja-build p7zip p7zip-full patch
  pkgconf python2.7 python3 python3-pyelftools python3-setuptools qemu-utils
  rsync scons squashfs-tools subversion swig texinfo uglifyjs upx-ucl unzip vim
  wget xmlto xxd zlib1g-dev
)

init() {
  group_start "Initialize build environment"

  sudo rm -rf /etc/apt/sources.list.d/* || true
  sudo -E apt-get -qq update
  sudo -E apt-get -qq install -y "${COMPILE_DEPENDS[@]}"
  sudo -E apt-get -qq --purge autoremove
  sudo -E apt-get -qq autoclean

  sudo timedatectl set-timezone "${TZ:-Asia/Shanghai}"

  sudo mkdir -p /workdir
  sudo chown -R "$USER:$USER" /workdir

  mkdir -p "$CCACHE_DIR" "$CARGO_HOME"

  {
    echo "CCACHE_DIR=$CCACHE_DIR"
    echo "CARGO_HOME=$CARGO_HOME"
  } >> "$GITHUB_ENV"

  group_end
}

prepare_source() {
  : "${PROFILE_DIR:?PROFILE_DIR is required}"
  : "${REPO_URL:?REPO_URL is required}"
  : "${REPO_BRANCH:?REPO_BRANCH is required}"

  group_start "Clone source"

  if [[ ! -d "$OPENWRT_ROOT/.git" ]]; then
    git clone -b "$REPO_BRANCH" --single-branch "$REPO_URL" "$OPENWRT_ROOT"
  else
    log_info "Source already exists: $OPENWRT_ROOT"
  fi

  ln -sfn "$OPENWRT_ROOT" "${GITHUB_WORKSPACE}/openwrt"

  group_end

  group_start "Apply profile hooks and feeds"

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

  group_end
}

apply_profile() {
  : "${PROFILE_DIR:?PROFILE_DIR is required}"

  group_start "Apply profile files"

  copy_dir_if_exists "${PROFILE_DIR}/files" "${OPENWRT_ROOT}/files"
  copy_file_if_exists "${PROFILE_DIR}/.config" "${OPENWRT_ROOT}/.config"

  group_end
}

download_deps() {
  group_start "Download dependencies"

  cd "$OPENWRT_ROOT"
  make defconfig
  make download -j"$(nproc)"

  find dl -size -1024c -exec ls -l {} \; || true
  find dl -size -1024c -exec rm -f {} \; || true

  group_end
}

compile_fw() {
  group_start "Compile firmware"

  cd "$OPENWRT_ROOT"
  echo -e "$(nproc) thread compile"

  if make -j"$(nproc)"; then
    log_info "Parallel build succeeded"
  elif make -j1; then
    log_warn "Parallel build failed, single-job build succeeded"
  else
    log_warn "Single-job build failed, retry with verbose log"
    make -j1 V=s
  fi

  local device_name=""
  if grep '^CONFIG_TARGET.*DEVICE.*=y' .config > /tmp/device_name.tmp 2>/dev/null; then
    device_name="$(sed -r 's/.*DEVICE_(.*)=y/\1/' /tmp/device_name.tmp | head -n1)"
  fi

  local file_date
  file_date="$(timestamp_compact)"

  append_env "DEVICE_NAME" "${device_name}"
  append_env "FILE_DATE" "${file_date}"

  group_end
}

prepare_release() {
  : "${PROFILE_ID:?PROFILE_ID is required}"
  : "${PROFILE_NAME:?PROFILE_NAME is required}"
  : "${FILE_DATE:?FILE_DATE is required}"

  group_start "Prepare release metadata"

  local release_tag="${PROFILE_ID}-$(timestamp_tag)"
  local release_name="${PROFILE_NAME} ${FILE_DATE}"
  local release_body="${GITHUB_WORKSPACE}/release.txt"

  {
    echo "Profile: ${PROFILE_NAME}"
    echo "Profile ID: ${PROFILE_ID}"
    echo "Branch: ${REPO_BRANCH}"
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
  init)
    init
    ;;
  prepare-source)
    prepare_source
    ;;
  apply-profile)
    apply_profile
    ;;
  download)
    download_deps
    ;;
  compile)
    compile_fw
    ;;
  prepare-release)
    prepare_release
    ;;
  *)
    log_error "Unknown command: ${1:-}"
    exit 1
    ;;
esac
