#!/bin/bash

rm -rf KernelSU
echo "Removed successfully!"
curl -LSs "https://raw.githubusercontent.com/ShirkNeko/KernelSU/susfs/kernel/setup.sh" | bash -s susfs_patch
echo "Cloned successfully!"

rm susfs4ksu
echo "Removed successfully!"
git clone https://gitlab.com/simonpunk/susfs4ksu.git -b gki-android13-5.15
echo "Cloned successfully!"
cp susfs4ksu/kernel_patches/50_add_susfs_in_gki-android13-5.15.patch .
cp susfs4ksu/kernel_patches/fs/* fs/
cp susfs4ksu/kernel_patches/include/linux/* include/linux/
patch -p1 < 50_add_susfs_in_gki-android13-5.15.patch
echo "Patched Kernel successfully!"

rm kernel_patches
echo "Removed successfully!"
git clone https://github.com/WildPlusKernel/kernel_patches.git
echo "Cloned successfully!"
cp kernel_patches/69_hide_stuff.patch .
cp kernel_patches/hooks/new_hooks.patch .
patch -p1 -F 3 < 69_hide_stuff.patch
patch -p1 -F 3 < new_hooks.patch 

echo "CONFIG_KSU=y" >> ./common/arch/arm64/configs/gki_defconfig
echo "CONFIG_KSU_HOOK=y" >> ./common/arch/arm64/configs/gki_defconfig
echo "CONFIG_KSU_WITH_KPROBES=n" >> ./common/arch/arm64/configs/gki_defconfig
echo "CONFIG_KSU_SUSFS=y" >> ./common/arch/arm64/configs/gki_defconfig
echo "CONFIG_KSU_SUSFS_HAS_MAGIC_MOUNT=y" >> ./common/arch/arm64/configs/gki_defconfig
echo "CONFIG_KSU_SUSFS_SUS_PATH=y" >> ./common/arch/arm64/configs/gki_defconfig
echo "CONFIG_KSU_SUSFS_SUS_MOUNT=y" >> ./common/arch/arm64/configs/gki_defconfig
echo "CONFIG_KSU_SUSFS_AUTO_ADD_SUS_KSU_DEFAULT_MOUNT=y" >> ./common/arch/arm64/configs/gki_defconfig
echo "CONFIG_KSU_SUSFS_AUTO_ADD_SUS_BIND_MOUNT=y" >> ./common/arch/arm64/configs/gki_defconfig
echo "CONFIG_KSU_SUSFS_SUS_KSTAT=y" >> ./common/arch/arm64/configs/gki_defconfig
echo "CONFIG_KSU_SUSFS_SUS_OVERLAYFS=n" >> ./common/arch/arm64/configs/gki_defconfig
echo "CONFIG_KSU_SUSFS_TRY_UMOUNT=y" >> ./common/arch/arm64/configs/gki_defconfig
echo "CONFIG_KSU_SUSFS_AUTO_ADD_TRY_UMOUNT_FOR_BIND_MOUNT=y" >> ./common/arch/arm64/configs/gki_defconfig
echo "CONFIG_KSU_SUSFS_SPOOF_UNAME=y" >> ./common/arch/arm64/configs/gki_defconfig
echo "CONFIG_KSU_SUSFS_ENABLE_LOG=y" >> ./common/arch/arm64/configs/gki_defconfig
echo "CONFIG_KSU_SUSFS_HIDE_KSU_SUSFS_SYMBOLS=y" >> ./common/arch/arm64/configs/gki_defconfig
echo "CONFIG_KSU_SUSFS_SPOOF_CMDLINE_OR_BOOTCONFIG=y" >> ./common/arch/arm64/configs/gki_defconfig
echo "CONFIG_KSU_SUSFS_OPEN_REDIRECT=y" >> ./common/arch/arm64/configs/gki_defconfig
echo "CONFIG_KSU_SUSFS_SUS_SU=n" >> ./common/arch/arm64/configs/gki_defconfig
sed -i '$s|echo "\$res"|echo "\$res-liqideqq"|' ./scripts/setlocalversion
sed -i 's/check_defconfig//' ./common/build.config.gki
echo "Patched Kernel successfully!"

chmod +x  build.sh
sh build.sh
echo "Kernel Compiled successfully!"
