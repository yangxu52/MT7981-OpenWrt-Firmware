# **MT7981 OpenWrt Firmware** [Please Star⚝ ↗]

MT7981 OpenWrt Firmware, compile by Github Actions  
[![LICENSE](https://img.shields.io/badge/license-apache--2.0-green.svg?style=flat-square&label=LICENSE)](https://github.com/yangxu52/CMCC-RAX3000M-OpenWrt-Firmware/blob/main/LICENSE)&nbsp;
![GitHub Stars](https://img.shields.io/github/stars/yangxu52/CMCC-RAX3000M-OpenWrt-Firmware.svg?style=flat-square&label=Stars&logo=github)&nbsp;
![GitHub Forks](https://img.shields.io/github/forks/yangxu52/CMCC-RAX3000M-OpenWrt-Firmware.svg?style=flat-square&label=Forks&logo=github)
&emsp;

## **1. Instruction | 介绍**

### **1.1 Source Code | 源码使用**

- [Immortalwrt @hanwckf](https://github.com/hanwckf/immortalwrt-mt798x)

- [Application passwall @xiaoruoji](https://github.com/xiaorouji/openwrt-passwall)

- [Luci theme Argon @jerrykuku](https://github.com/jerrykuku/luci-theme-argon)

- ······

### **1.2 Major Modifications | 主要修改**

- **Remove all USB support**  
  USB interface only has charging function. **Important !**

- **Network Turbo ACC**  
  Base on MTK HNAT, Power by [@hanwckf](https://github.com/hanwckf)

- **Add IPv6 full support**

- **Add UPNP support**

- **Add KMS Server**

- **Add Syncdial & mwan3**  
  Support multi-wan access and load balancing,suport PPPoE and others.

- **Add ~~Passwall~~**  
  include xray-core, sing-box.

- **Others**  
  &emsp;

## **2. Use Guide | 使用指南**

### **2.1 Language | 语言**

1. Open [Web Admin](http://192.168.7.1) (default: 192.168.7.1) in your browser and login (default: `root` `password`).
2. Open Menu `(系统|System)` -> `(系统|System)`, swith tab `(语言和界面|Language and Style)`
3. Change the `Language` select's option. (auto=English)
4. Click the `(保存&应用|SAVE&APPLY)` button to save. Finally,refresh browser.  
   &emsp;

<!-- ### **2.2 Wireless Power | 无线功率**

1. Open [Web Admin](http://192.168.1.1) (default: 192.168.1.1) in your browser and login (default: `root` `password`).
2. Open Menu `(系统|System)` -> `(启动项|Startup)`, slide to the bottom.
3. Add some shell command in `(本地启动脚本|Local Startup Script)`, before `exit 0`
   ```shell
   iwconfig wlan0 txpower 23
   iwconfig wlan1 txpower 23
   ```
   The `wlan0` represent 2.4G,`wlan1` represent 5G. `23` reresent submit power (max:`31`).
   Recommend: Between `23` and `27`.Power is proportional to signal and inversely proportional to wireless throughput.
4. Click the `(保存&应用|SAVE&APPLY)` button to save. Finally,refresh browser.
   &emsp;

### **2.3 Network Turbo ACC | 网络加速**

1. Open [Web Admin](http://192.168.1.1) (default: 192.168.1.1) in your browser and login (default: `root` `password`).
2. Open Menu (网络|Network) -> (Turbo ACC Center|Turbo ACC 网络加速).
3. Selected the `Shortcut-FE flow offloading | Shortcut-FE 流量分载` and `BBR CCA | BBR 拥塞控制算法`.Change `FullCone NAT | 全锥型 NAT`'s Option to `High Performing Mode | 高性能模式`
4. Click the `(保存&应用|SAVE&APPLY)` button to save.
   &emsp; -->

## **3. Tanks | 致谢**

- [hanwckf](https://github.com/hanwckf)
- [xiaoruoji](https://github.com/xiaoruoji)
- [jerrykuku](https://github.com/jerrykuku)
- [P3TERX](https://github.com/P3TERX)
- Others
