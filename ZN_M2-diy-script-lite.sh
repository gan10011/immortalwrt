#!/bin/bash

# 精简版配置 - 针对低内存设备优化

# 1. 基本网络配置
sed -i 's/192.168.100.1/192.168.1.1/g' package/base-files/files/bin/config_generate

# 2. 移除高内存占用组件
# 禁用NSS相关功能
sed -i '/CONFIG_PACKAGE_kmod-qca-nss/d' .config
echo "# CONFIG_PACKAGE_kmod-qca-nss-drv is not set" >> .config
echo "# CONFIG_PACKAGE_kmod-qca-nss-ecm is not set" >> .config

# 禁用USB相关功能
sed -i '/CONFIG_PACKAGE_kmod-usb/d' .config
echo "# CONFIG_PACKAGE_kmod-usb-core is not set" >> .config
echo "# CONFIG_PACKAGE_kmod-usb2 is not set" >> .config
echo "# CONFIG_PACKAGE_kmod-usb3 is not set" >> .config

# 3. 移除不必要的包
remove_packages=(
  "luci-app-dockerman"
  "luci-app-diskman"
  "luci-app-aria2"
  "luci-app-transmission"
  "luci-app-v2ray-server"
  "luci-app-qbittorrent"
  "ddns-scripts-cloudflare"
  "luci-app-frpc"
  "luci-app-frps"
)

for pkg in "${remove_packages[@]}"; do
  sed -i "/CONFIG_PACKAGE_$pkg/d" .config
  echo "# CONFIG_PACKAGE_$pkg is not set" >> .config
done

# 4. 启用低内存优化选项
echo "CONFIG_BUSYBOX_CONFIG_FEATURE_USE_INITTAB=n" >> .config
echo "CONFIG_BUSYBOX_CONFIG_FEATURE_EDITING=y" >> .config
echo "CONFIG_BUSYBOX_CONFIG_FEATURE_SHARED_BUSYBOX=y" >> .config
echo "CONFIG_KERNEL_SLOB=y" >> .config  # 使用SLOB内存分配器节省内存

# 5. 精简文件系统
echo "CONFIG_TARGET_ROOTFS_SQUASHFS=y" >> .config
echo "CONFIG_TARGET_IMAGES_GZIP=y" >> .config
echo "CONFIG_TARGET_ROOTFS_PARTSIZE=16" >> .config  # 减小根分区大小

# 6. 禁用调试和日志功能
echo "CONFIG_DEBUG_FS=n" >> .config
echo "CONFIG_DEBUG_KERNEL=n" >> .config
echo "CONFIG_SLUB_DEBUG=n" >> .config
echo "CONFIG_PRINTK=n" >> .config

# 7. 精简网络功能
echo "CONFIG_PACKAGE_iptables-mod-extra=n" >> .config
echo "CONFIG_PACKAGE_iptables-mod-ipsec=n" >> .config
echo "CONFIG_PACKAGE_iptables-mod-tproxy=n" >> .config

# 8. 更新feeds并应用配置
./scripts/feeds update -a
./scripts/feeds install -a
make defconfig

# 9. 版本信息
date_version=$(date +"%y.%m.%d")
sed -i "s/DISTRIB_REVISION='.*'/DISTRIB_REVISION='Lite-R${date_version}'/g" package/base-files/files/etc/openwrt_release

echo "精简版配置完成 - 适合低内存设备使用"
