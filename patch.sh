#!/bin/bash


rm -rf KernelSU-Next
echo "Removed successfully!"

curl -LSs "https://raw.githubusercontent.com/rifsxd/KernelSU-Next/next/kernel/setup.sh" | bash -s next
echo "Cloned successfully!"

rm susfs4ksu
echo "Removed successfully!"

git clone https://gitlab.com/simonpunk/susfs4ksu.git -b gki-android13-5.15
echo "Cloned successfully!"



cp susfs4ksu/kernel_patches/KernelSU/10_enable_susfs_for_ksu.patch KernelSU-Next/

cp susfs4ksu/kernel_patches/50_add_susfs_in_gki-android13-5.15.patch .

cp susfs4ksu/kernel_patches/fs/* fs/

cp susfs4ksu/kernel_patches/include/linux/* include/linux/


cd KernelSU-Next/

patch -p1 < 10_enable_susfs_for_ksu.patch

cd ..

cd fix
cp apk_sign.c   ../KernelSU-Next/kernel/
echo "Patched apk_sign successfully!"
cp core_hook.c  ../KernelSU-Next/kernel/
echo "Patched core_hook successfully!"
cp selinux.c    ../KernelSU-Next/kernel/selinux/
echo "Patched selinux successfully!"

echo "Patched Susfs successfully!"

cd ..

patch -p1 < 50_add_susfs_in_gki-android13-5.15.patch
echo "Patched Kernel successfully!"

chmod +x  build.sh
sh build.sh
echo "Kernel Compiled successfully!"
