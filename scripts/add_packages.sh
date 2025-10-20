#!/bin/bash

# {{ Add luci-app-diskman
(cd friendlywrt && {
    mkdir -p package/luci-app-diskman
    wget https://raw.githubusercontent.com/lisaac/luci-app-diskman/master/applications/luci-app-diskman/Makefile.old -O package/luci-app-diskman/Makefile
})
cat >> configs/rockchip/01-nanopi <<EOL
CONFIG_PACKAGE_luci-app-diskman=y
CONFIG_PACKAGE_luci-app-diskman_INCLUDE_btrfs_progs=y
CONFIG_PACKAGE_luci-app-diskman_INCLUDE_lsblk=y
CONFIG_PACKAGE_luci-i18n-diskman-zh-cn=y
CONFIG_PACKAGE_smartmontools=y
# DAE
CONFIG_KERNEL_DEBUG_INFO=y
CONFIG_KERNEL_DEBUG_INFO_REDUCED=n
CONFIG_KERNEL_DEBUG_INFO_BTF=y
CONFIG_KERNEL_CGROUPS=y
CONFIG_KERNEL_CGROUP_BPF=y
CONFIG_KERNEL_BPF_EVENTS=y
CONFIG_BPF_TOOLCHAIN_HOST=y
CONFIG_KERNEL_XDP_SOCKETS=y
CONFIG_PACKAGE_kmod-xdp-sockets-diag=y
CONFIG_PACKAGE_luci-app-dae=y

# SAVING RAM FOR DAE
CONFIG_PACKAGE_zram-swap=y
CONFIG_PACKAGE_kmod-lib-lz4=y
CONFIG_PACKAGE_kmod-lib-lzo=y
CONFIG_PACKAGE_kmod-lib-zstd=y

EOL
# }}

# {{ Add luci-theme-argon
(cd friendlywrt/package && {
    [ -d luci-theme-argon ] && rm -rf luci-theme-argon
    git clone https://github.com/jerrykuku/luci-theme-argon.git --depth 1 -b master
})
echo "CONFIG_PACKAGE_luci-theme-argon=y" >> configs/rockchip/01-nanopi
sed -i -e 's/function init_theme/function old_init_theme/g' friendlywrt/target/linux/rockchip/armv8/base-files/root/setup.sh
cat > /tmp/appendtext.txt <<EOL
function init_theme() {
    if uci get luci.themes.Argon >/dev/null 2>&1; then
        uci set luci.main.mediaurlbase="/luci-static/argon"
        uci commit luci
    fi
}
EOL
sed -i -e '/boardname=/r /tmp/appendtext.txt' friendlywrt/target/linux/rockchip/armv8/base-files/root/setup.sh
# }}
