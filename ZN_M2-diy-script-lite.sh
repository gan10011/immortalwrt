#!/bin/bash
# 兆能M2精简版配置脚本 - 针对低内存设备优化
# 移除NSS/USB功能，只保留基础WiFi功能

echo "开始应用兆能M2精简版配置..."

# 1. 基本网络配置
sed -i 's/192.168.100.1/192.168.1.1/g' package/base-files/files/bin/config_generate
echo "✅ 设置默认IP地址: 192.168.1.1"

# 2. 彻底禁用NSS相关功能
nss_packages=(
    "kmod-qca-nss-drv"
    "kmod-qca-nss-drv-pppoe"
    "kmod-qca-nss-ecm"
    "kmod-qca-nss-gmac"
    "kmod-qca-nss-drv-bridge-mgr"
    "qca-nss-fw2-ipq60xx"
    "qca-nss-fw2-ipq60xx-64"
)

for pkg in "${nss_packages[@]}"; do
    sed -i "/CONFIG_PACKAGE_${pkg}/d" .config
    echo "# CONFIG_PACKAGE_${pkg} is not set" >> .config
done
echo "✅ 已完全禁用NSS加速功能"

# 3. 彻底禁用USB相关功能
usb_packages=(
    "kmod-usb-core"
    "kmod-usb2"
    "kmod-usb3"
    "kmod-usb-storage"
    "kmod-usb-storage-extras"
    "kmod-usb-uhci"
    "kmod-usb-ohci"
    "kmod-usb-acm"
    "kmod-usb-net"
    "kmod-usb-serial"
)

for pkg in "${usb_packages[@]}"; do
    sed -i "/CONFIG_PACKAGE_${pkg}/d" .config
    echo "# CONFIG_PACKAGE_${pkg} is not set" >> .config
done
echo "✅ 已完全禁用USB相关功能"

# 4. 移除不必要的包(只保留最基础功能)
remove_packages=(
    "luci-app-dockerman"
    "luci-app-diskman"
    "luci-app-aria2"
    "luci-app-transmission"
    "luci-app-v2ray-server"
    "luci-app-qbittorrent"
    "ddns-scripts-*"
    "luci-app-frpc"
    "luci-app-frps"
    "luci-app-upnp"
    "luci-app-wol"
    "luci-app-vpn-policy-routing"
    "luci-app-samba4"
    "luci-app-ttyd"
    "luci-app-watchcat"
    "luci-app-statistics"
    "luci-app-uhttpd"
    "luci-app-commands"
    "luci-app-filetransfer"
    "luci-app-https-dns-proxy"
    "luci-app-advanced-reboot"
    "ip6tables"
    "odhcp6c"
    "kmod-ipv6"
    "kmod-ipt-nat6"
    "6in4"
    "6rd"
    "6to4"
)

for pkg in "${remove_packages[@]}"; do
    sed -i "/CONFIG_PACKAGE_${pkg}/d" .config
    echo "# CONFIG_PACKAGE_${pkg} is not set" >> .config
done
echo "✅ 已移除非必要软件包"

# 5. 启用低内存优化选项
echo "CONFIG_BUSYBOX_CONFIG_FEATURE_USE_INITTAB=n" >> .config
echo "CONFIG_BUSYBOX_CONFIG_FEATURE_SHARED_BUSYBOX=y" >> .config
echo "CONFIG_KERNEL_SLOB=y" >> .config
echo "CONFIG_CC_OPTIMIZE_FOR_SIZE=y" >> .config
echo "CONFIG_KERNEL_GZIP=y" >> .config
echo "✅ 启用低内存优化选项"

# 6. 精简文件系统
echo "CONFIG_TARGET_ROOTFS_SQUASHFS=y" >> .config
echo "CONFIG_TARGET_IMAGES_GZIP=y" >> .config
echo "CONFIG_TARGET_ROOTFS_PARTSIZE=8" >> .config
echo "CONFIG_TARGET_KERNEL_PARTSIZE=8" >> .config
echo "✅ 精简文件系统设置完成"

# 7. 禁用调试和日志功能
echo "CONFIG_DEBUG_FS=n" >> .config
echo "CONFIG_DEBUG_KERNEL=n" >> .config
echo "CONFIG_SLUB_DEBUG=n" >> .config
echo "CONFIG_PRINTK=n" >> .config
echo "CONFIG_KERNEL_DEBUG_INFO=n" >> .config
echo "✅ 禁用调试和日志功能"

# 8. 精简网络功能
network_packages=(
    "iptables-mod-extra"
    "iptables-mod-ipsec"
    "iptables-mod-tproxy"
    "kmod-ipt-offload"
    "kmod-nft-offload"
    "kmod-sched"
    "kmod-sched-cake"
    "kmod-sched-connmark"
    "kmod-sched-core"
)

for pkg in "${network_packages[@]}"; do
    sed -i "/CONFIG_PACKAGE_${pkg}/d" .config
    echo "# CONFIG_PACKAGE_${pkg} is not set" >> .config
done
echo "✅ 精简网络功能完成"

# 9. 保留基础WiFi功能
wifi_packages=(
    "hostapd-common"
    "kmod-ath11k"
    "wpad-basic"
    "kmod-cfg80211"
    "kmod-mac80211"
)

for pkg in "${wifi_packages[@]}"; do
    echo "CONFIG_PACKAGE_${pkg}=y" >> .config
done
echo "✅ 保留基础WiFi功能"

# 10. 版本信息（不涉及配置更改，保留）
date_version=$(date +"%y.%m.%d")
sed -i "s/DISTRIB_REVISION='.*'/DISTRIB_REVISION='Lite-${date_version}'/g" package/base-files/files/etc/openwrt_release
sed -i "s/DISTRIB_DESCRIPTION='.*'/DISTRIB_DESCRIPTION='兆能M2精简版(无NSS/USB)'/g" package/base-files/files/etc/openwrt_release

echo "=============================================="
echo "✅ 精简版配置完成 - 适合64-128MB内存设备使用"
echo "✅ 移除功能: NSS加速, USB支持, IPv6, 高级网络功能"
echo "✅ 保留功能: 基础路由, 2.4G/5G WiFi, 基本防火墙"
echo "=============================================="
