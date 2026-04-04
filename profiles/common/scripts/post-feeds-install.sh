#!/usr/bin/env bash
set -euo pipefail

CONFIG_GENERATE="package/base-files/files/bin/config_generate"
MTWIFI_SH="package/mtk/applications/mtwifi-cfg/files/mtwifi.sh"

if [[ -n "${MODIFY_HOSTNAME:-}" ]]; then
  echo '>>> Update Hostname >>>'
  sed -i "s/hostname='ImmortalWrt'/hostname='${MODIFY_HOSTNAME}'/g" "${CONFIG_GENERATE}"
  grep -n "hostname='${MODIFY_HOSTNAME}'" "${CONFIG_GENERATE}"
  echo '<<< Completed Update Hostname <<<'
fi

if [[ -n "${MODIFY_IP:-}" || -n "${MODIFY_ADDR_OFFSET:-}" ]]; then
  : "${MODIFY_IP:?MODIFY_IP is required when modifying default IP}"
  : "${MODIFY_ADDR_OFFSET:?MODIFY_ADDR_OFFSET is required when modifying default IP}"

  echo '>>> Update Default IP >>>'
  sed -i "s/ipad=\${ipaddr:-\"192.168.1.1\"}/ipad=\${ipaddr:-\"${MODIFY_IP}\"}/g" "${CONFIG_GENERATE}"
  sed -i "s/addr_offset=2/addr_offset=${MODIFY_ADDR_OFFSET}/g" "${CONFIG_GENERATE}"
  grep -n "${MODIFY_IP}\\|addr_offset=${MODIFY_ADDR_OFFSET}" "${CONFIG_GENERATE}"
  echo '<<< Completed Update Default IP <<<'
fi

echo '>>> Update NTP Servers >>>'
sed -i "s/time1.apple.com/ntp.aliyun.com/g" "${CONFIG_GENERATE}"
sed -i "s/time1.google.com/ntp.tencent.com/g" "${CONFIG_GENERATE}"
sed -i "s/time.cloudflare.com/time.ustc.edu.cn/g" "${CONFIG_GENERATE}"
sed -i "s/pool.ntp.org/cn.pool.ntp.org/g" "${CONFIG_GENERATE}"
grep -n "ntp.aliyun.com\\|ntp.tencent.com\\|time.ustc.edu.cn\\|cn.pool.ntp.org" "${CONFIG_GENERATE}"
echo '<<< Completed Update NTP Servers <<<'

if [[ -n "${MODIFY_WIFI_2G_SSID:-}" ]]; then
  echo '>>> Update 2.4G Wi-Fi SSID >>>'
  sed -i "s/ssid=\"ImmortalWrt-2.4G\"/ssid=\"${MODIFY_WIFI_2G_SSID}\"/g" "${MTWIFI_SH}"
  grep -n "ssid=\"${MODIFY_WIFI_2G_SSID}\"" "${MTWIFI_SH}"
  echo '<<< Completed Update 2.4G Wi-Fi SSID <<<'
fi

if [[ -n "${MODIFY_WIFI_5G_SSID:-}" ]]; then
  echo '>>> Update 5G Wi-Fi SSID >>>'
  sed -i "s/ssid=\"ImmortalWrt-5G\"/ssid=\"${MODIFY_WIFI_5G_SSID}\"/g" "${MTWIFI_SH}"
  grep -n "ssid=\"${MODIFY_WIFI_5G_SSID}\"" "${MTWIFI_SH}"
  echo '<<< Completed Update 5G Wi-Fi SSID <<<'
fi
