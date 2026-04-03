#!/usr/bin/env bash
set -euo pipefail

echo '替换golang到1.24.x'
rm -rf feeds/packages/lang/golang
git clone -b 24.x --single-branch --depth 1 https://github.com/sbwml/packages_lang_golang feeds/packages/lang/golang
echo '=========Replace golang OK!========='

echo '替换rust到1.94.x'
rm -rf feeds/packages/lang/rust
git clone -b 1.94.x --single-branch --depth 1 https://github.com/yangxu52/openwrt-rust-backports feeds/packages/lang/rust
./scripts/feeds update -i packages
echo '=========Replace rust OK!========='

echo '替换jerrykuku的luci argon主题'
rm -rf feeds/luci/themes/luci-theme-argon
git clone -b v2.4.3 --single-branch --depth 1 https://github.com/jerrykuku/luci-theme-argon feeds/luci/themes/luci-theme-argon
./scripts/feeds update -i luci
echo '=========Replace luci theme argon OK!========='

echo '修改Passwall检测规则'
sed -i 's/-socket iptables-mod-/-/g' feeds/luci/applications/luci-app-passwall/root/usr/share/passwall/app.sh
echo '=========ALTER passwall denpendcies check OK!========='
