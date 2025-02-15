#!/bin/bash
$GIT_VERSION=kernel-4.19
$GIT_LINK="https://gitlab.com/simonpunk/susfs4ksu.git"
$KSU_NAME=KernelSU
git clone -b $KERNEL_VERSION $GIT_LINK susfs4ksu
cp susfs4ksu/kernel_patches/fs/* fs/
cp susfs4ksu/kernel_patches/include/linux/* include/linux/
cp susfs4ksu/kernel_patches/KernelSU/10_enable_susfs_for_ksu.patch ./
cp susfs4ksu/kernel_patches/50_add_susfs_in_$GIT_VERSION.patch ./
cd $KSU_NAME
patch -p1 < 10_enable_susfs_for_ksu.patch
cd ../
patch -p1 < 50_add_susfs_in_$GIT_VERSION.patch
