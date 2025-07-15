#!/bin/bash
#
#Copyright 2021-present yangxu52<https://github.com/yangxu52>
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

echo '修改主机名'
sed -i "s/hostname='ImmortalWrt'/hostname='NX30PRO'/g" package/base-files/files/bin/config_generate
cat package/base-files/files/bin/config_generate |grep hostname=
echo '=========Alert hostname OK!========='

echo '修改默认IP'
sed -i 's/ipad=${ipaddr:-"192.168.1.1"}/ipad=${ipaddr:-"192.168.5.1"}/g' package/base-files/files/bin/config_generate
sed -i 's/addr_offset=2/addr_offset=6/g' package/base-files/files/bin/config_generate
sed -i 's/${ipaddr:-"192.168.$((addr_offset++)).1"}/${ipaddr:-"192.168.$((addr_offset++)).1"}/g' package/base-files/files/bin/config_generate
cat package/base-files/files/bin/config_generate |grep hostname=
echo '=========Alert Default IP OK!========='

echo '修改NTP服务器'
sed -i "s/time1.apple.com/ntp.aliyun.com/g" package/base-files/files/bin/config_generate
sed -i "s/time1.google.com/ntp.tencent.com/g" package/base-files/files/bin/config_generate
sed -i "s/time.cloudflare.com/time.ustc.edu.cn/g" package/base-files/files/bin/config_generate
sed -i "s/pool.ntp.org/cn.pool.ntp.org/g" package/base-files/files/bin/config_generate
echo '=========Alert NTP Server OK!========='

echo '修改闭源驱动2G wifi名称'
sed -i 's/ssid="ImmortalWrt-2.4G"/ssid="NX30PRO-2.4G"/g' package/mtk/applications/mtwifi-cfg/files/mtwifi.sh
sed -i 's/ssid="OpenWRT-2.4G/ssid="NX30PRO-2.4G/g' package/mtk/drivers/wifi-profile/files/common/mt7981/lib/wifi/mtk.sh
echo '=========Alert 2.4G wifi name OK!========='

echo '修改闭源驱动5G wifi名称'
sed -i 's/ssid="ImmortalWrt-5G"/ssid="NX30PRO-5G"/g' package/mtk/applications/mtwifi-cfg/files/mtwifi.sh
sed -i 's/ssid="OpenWRT-5G/ssid="NX30PRO-5G/g' package/mtk/drivers/wifi-profile/files/common/mt7981/lib/wifi/mtk.sh
echo '=========Alert 5G wifi name OK!========='