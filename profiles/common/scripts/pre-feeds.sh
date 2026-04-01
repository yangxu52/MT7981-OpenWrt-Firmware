#!/usr/bin/env bash
set -euo pipefail

prepend_feed_if_missing() {
  local line="$1"
  grep -qxF "$line" feeds.conf.default || sed -i "1i ${line}" feeds.conf.default
}

echo '添加Passwall依赖feeds'
prepend_feed_if_missing 'src-git passwall_luci https://github.com/Openwrt-Passwall/openwrt-passwall.git;main'
prepend_feed_if_missing 'src-git passwall_packages https://github.com/Openwrt-Passwall/openwrt-passwall-packages.git;main'
echo '=========Add passwall feeds source OK!========='
