#!/bin/bash
#
#Copyright 2021-2024 yangxu52<https://github.com/yangxu52>
#
#Licensed under the Apache License, Version 2.0 (the "License");
#you may not use this file except in compliance with the License.
#You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
#Unless required by applicable law or agreed to in writing, software
#distributed under the License is distributed on an "AS IS" BASIS,
#WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#See the License for the specific language governing permissions and
#limitations under the License.

echo '替换Passwall软件'
rm -rf feeds/luci/applications/luci-app-passwall
git clone -b main --single-branch https://github.com/xiaorouji/openwrt-passwall feeds/luci/applications/luci-app-passwall
mv feeds/luci/applications/luci-app-passwall/luci-app-passwall/* feeds/luci/applications/luci-app-passwall/
rm -rf feeds/luci/applications/luci-app-passwall/luci-app-passwall
echo '=========Replace passwall source OK!========='

echo '替换jerrykuku的luci argon主题'
rm -rf feeds/luci/themes/luci-theme-argon
git clone -b master --single-branch https://github.com/jerrykuku/luci-theme-argon feeds/luci/themes/luci-theme-argon
echo '=========Replace luci theme argon OK!========='
