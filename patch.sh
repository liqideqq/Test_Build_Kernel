#!/bin/bash


rm -rf KernelSU-Next
echo "Removed successfully!"

curl -LSs "https://raw.githubusercontent.com/tiann/KernelSU/main/kernel/setup.sh" | bash -s main
echo "Cloned successfully!"

rm susfs4ksu
echo "Removed successfully!"

git clone https://gitlab.com/simonpunk/susfs4ksu.git -b gki-android13-5.15
echo "Cloned successfully!"



cp susfs4ksu/kernel_patches/KernelSU/10_enable_susfs_for_ksu.patch KernelSU/

cp susfs4ksu/kernel_patches/50_add_susfs_in_gki-android13-5.15.patch .

cp susfs4ksu/kernel_patches/fs/* fs/

cp susfs4ksu/kernel_patches/include/linux/* include/linux/


cd KernelSU/

patch -p1 < 10_enable_susfs_for_ksu.patch

cd ..

patch -p1 < 50_add_susfs_in_gki-android13-5.15.patch
echo "Patched Kernel successfully!"

chmod +x  build.sh
sh build.sh
echo "Kernel Compiled successfully!"
