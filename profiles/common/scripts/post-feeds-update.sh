#!/usr/bin/env bash
set -euo pipefail

echo '>>> Replace Golang with 1.24.x >>>'
rm -rf feeds/packages/lang/golang
git clone -b 24.x --single-branch --depth 1 https://github.com/sbwml/packages_lang_golang feeds/packages/lang/golang
echo '<<< Completed Replace Golang with 1.24.x <<<'

echo '>>> Replace Rust with 1.94.x >>>'
rm -rf feeds/packages/lang/rust
git clone -b 1.94.x --single-branch --depth 1 https://github.com/yangxu52/openwrt-rust-backports feeds/packages/lang/rust
./scripts/feeds update -i packages
echo '<<< Completed Replace Rust 1.94.x <<<'

echo '>>> Replace Luci Theme Argon >>>'
rm -rf feeds/luci/themes/luci-theme-argon
git clone -b v2.4.3 --single-branch --depth 1 https://github.com/jerrykuku/luci-theme-argon feeds/luci/themes/luci-theme-argon
./scripts/feeds update -i luci
echo '<<< Completed Replace Luci Theme Argon <<<'

echo '>>> Update Passwall TProxy Dependencies >>>'
sed -Ei 's/(^| )iptables-mod-socket( |$)/ /g; s/  +/ /g' feeds/luci/applications/luci-app-passwall/root/usr/share/passwall/app.sh
echo '<<< Completed Update Passwall TProxy Dependencies <<<'
