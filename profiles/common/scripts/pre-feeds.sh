#!/usr/bin/env bash
set -euo pipefail

prepend_feed_if_missing() {
  local line="$1"
  grep -qxF "$line" feeds.conf.default || sed -i "1i ${line}" feeds.conf.default
}

echo '添加Passwall依赖feeds'
prepend_feed_if_missing 'src-git passwall_luci https://github.com/Openwrt-Passwall/openwrt-passwall.git;main'
prepend_feed_if_missing 'src-git passwall_packages https://github.com/Openwrt-Passwall/openwrt-passwall-packages.git;main'
echo '=========Add passwall feeds OK!========='

echo '添加openwrt-forge feed'
prepend_feed_if_missing 'src-git forge https://github.com/yangxu52/openwrt-forge;openwrt-21.02-rust-1.94.1'
echo '=========Add openwrt-forge feed OK!========='
