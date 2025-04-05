#!/usr/bin/env bash
if [ -z "$1" ]; then
	echo "Currently, no selection has been made, defaulting to Mode 1."
	MODE=1
else
	MODE=$1
fi

KERNEL_VERSION=$(head -n 3 device_kernel/Makefile | grep -E 'VERSION|PATCHLEVEL' | awk '{print $3}' | paste -sd '.')
KERNEL=$(echo "$KERNEL_VERSION" | awk -F '.' '{print $1}')
PATCHLEVEL=$(echo "$KERNEL_VERSION" | awk -F '.' '{print $2}')
KERNELSU_SETUP="KernelSU-Next"
KERNELSU_BRANCH="next-susfs-dev"
SUSFS_BRANCH="kernel-$KERNEL.$PATCHLEVEL"

kernelsu(){
curl -LSs "https://raw.githubusercontent.com/$KERNELSU_SETUP/$KERNELSU_SETUP/refs/heads/next/kernel/setup.sh" | bash -s $KERNELSU_BRANCH
}

susfs(){
git clone https://gitlab.com/simonpunk/susfs4ksu.git -b $SUSFS_BRANCH
cp susfs4ksu/kernel_patches/fs/* fs/
cp susfs4ksu/kernel_patches/include/linux/* include/linux/
cp susfs4ksu/kernel_patches/50_add_susfs_in_kernel-$KERNEL.$PATCHLEVEL.patch ./
patch -p1 < 50_add_susfs_in_kernel-$KERNEL.$PATCHLEVEL.patch
}

if [ $MODE == 1 ]; then
	echo "======================"
	echo "=                    ="
	echo "=   Only  KernelSU   ="
	echo "=                    ="
	echo "======================"
	echo "  Please waiting 2s.  "
	sleep 2s
	kernelsu
elif [ $MODE == 2 ]; then
	echo "======================"
	echo "=                    ="
	echo "=     Only SuSFS     ="
	echo "=                    ="
	echo "======================"
	echo "  Please waiting 2s.  "
	sleep 2s
	susfs
elif [ $MODE == 3 ]; then
	echo "======================"
	echo "=                    ="
	echo "=  KernelSU + SuSFS  ="
	echo "=                    ="
	echo "======================"
	echo "  Please waiting 2s.  "
	sleep 2s
	kernelsu
	susfs
fi
