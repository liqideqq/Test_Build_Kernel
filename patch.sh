#!/bin/bash
set -e

# 配置常量
KERNEL_ROOT=$(pwd)
PATCH_DIR="${KERNEL_ROOT}/kernel_patches"
SUSFS_DIR="${KERNEL_ROOT}/susfs4ksu"
CONFIG_PATH="${KERNEL_ROOT}/common/arch/arm64/configs/gki_defconfig"

# 清理旧组件
cleanup() {
    rm -rf "${KERNEL_ROOT}/KernelSU" \
           "${SUSFS_DIR}" \
           "${PATCH_DIR}"
    echo "旧组件清理完成！"
}

# 获取依赖组件
fetch_dependencies() {
    # 获取 KernelSU
    curl -LSs "https://raw.githubusercontent.com/ShirkNeko/KernelSU/susfs/kernel/setup.sh" | bash -s susfs_patch
    echo "KernelSU 获取成功！"

    # 获取 SUSFS 组件
    git clone https://gitlab.com/simonpunk/susfs4ksu.git -b gki-android13-5.15 "${SUSFS_DIR}"
    git clone https://github.com/WildPlusKernel/kernel_patches.git "${PATCH_DIR}"
    echo "SUSFS 组件获取成功！"
}

# 准备内核补丁
prepare_patches() {
    # 复制主补丁
    cp "${SUSFS_DIR}/kernel_patches/50_add_susfs_in_gki-android13-5.15.patch" "${KERNEL_ROOT}/"
    
    # 复制辅助补丁
    cp "${PATCH_DIR}/69_hide_stuff.patch" "${KERNEL_ROOT}/"
    mkdir -p "${KERNEL_ROOT}/hooks"
    cp "${PATCH_DIR}/hooks/new_hooks.patch" "${KERNEL_ROOT}/hooks/"
}

# 部署文件系统
deploy_files() {
    # 部署 SUSFS 文件系统
    mkdir -p "${KERNEL_ROOT}/fs/susfs"
    cp -r "${SUSFS_DIR}/kernel_patches/fs/"* "${KERNEL_ROOT}/fs/susfs/"

    # 部署头文件
    mkdir -p "${KERNEL_ROOT}/include/linux/susfs"
    cp -r "${SUSFS_DIR}/kernel_patches/include/linux/"* "${KERNEL_ROOT}/include/linux/susfs/"
}

# 应用补丁
apply_patches() {
    cd "${KERNEL_ROOT}"
    patch -p1 < 50_add_susfs_in_gki-android13-5.15.patch
    patch -p1 -F 3 < 69_hide_stuff.patch
    patch -p1 -F 3 < hooks/new_hooks.patch
    echo "内核补丁应用完成！"
}

# 配置内核参数
configure_kernel() {
    # 追加 SUSFS 配置
    local configs=(
        "CONFIG_KSU=y"
        "CONFIG_KSU_SUSFS=y"
        "CONFIG_KSU_HOOK=y"
        "CONFIG_KSU_WITH_KPROBES=n"
        "CONFIG_KSU_SUSFS_HAS_MAGIC_MOUNT=y"
        "CONFIG_KSU_SUSFS_SUS_PATH=y"
        "CONFIG_KSU_SUSFS_SUS_MOUNT=y"
        "CONFIG_KSU_SUSFS_AUTO_ADD_SUS_KSU_DEFAULT_MOUNT=y"
        "CONFIG_KSU_SUSFS_AUTO_ADD_SUS_BIND_MOUNT=y"
        "CONFIG_KSU_SUSFS_SUS_KSTAT=y"
        "CONFIG_KSU_SUSFS_SUS_OVERLAYFS=n"
        "CONFIG_KSU_SUSFS_TRY_UMOUNT=y"
        "CONFIG_KSU_SUSFS_AUTO_ADD_TRY_UMOUNT_FOR_BIND_MOUNT=y"
        "CONFIG_KSU_SUSFS_SPOOF_UNAME=y"
        "CONFIG_KSU_SUSFS_ENABLE_LOG=y"
        "CONFIG_KSU_SUSFS_HIDE_KSU_SUSFS_SYMBOLS=y"
        "CONFIG_KSU_SUSFS_SPOOF_CMDLINE_OR_BOOTCONFIG=y"
        "CONFIG_KSU_SUSFS_OPEN_REDIRECT=y"
        "CONFIG_KSU_SUSFS_SUS_SU=n"
    )

    for config in "${configs[@]}"; do
        echo "${config}" >> "${CONFIG_PATH}"
    done

    # 修改版本标识
    sed -i 's|echo "$res"|echo "$res-liqideqq"|' "${KERNEL_ROOT}/scripts/setlocalversion"
    echo "内核配置更新完成！"
}

# 编译内核
build_kernel() {
    chmod +x build.sh
    ./build.sh
    echo "内核编译完成！"
}

# 主执行流程
main() {
    cleanup
    fetch_dependencies
    prepare_patches
    deploy_files
    apply_patches
    configure_kernel
    build_kernel
}

main
