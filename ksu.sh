#!/usr/bin/env bash
if [ -z "$1" ]; then
	echo "Currently, no selection has been made, defaulting to Mode 1."
	MODE=1
else
	MODE=$1
fi

# Kernel Version
KERNEL_VERSION=$(head -n 3 Makefile | grep -E 'VERSION|PATCHLEVEL' | awk '{print $3}' | paste -sd '.')
KERNEL=$(echo "$KERNEL_VERSION" | awk -F '.' '{print $1}')
PATCHLEVEL=$(echo "$KERNEL_VERSION" | awk -F '.' '{print $2}')

# KernelSU / SuSFS
SUSFS_BRANCH="kernel-$KERNEL.$PATCHLEVEL"

KERNELSU_AUTHOR="rsuntk"
KERNELSU_SETUP="KernelSU"
KERNELSU_BRANCH="next-susfs-dev"

# KernelSU Manual Hook
HOOK_MODE="none" # all -> kernel+ksu , ksu -> ksu , kernel -> kernel

if [ "$HOOK_MODE" == "all" ]; then
	bash normal_patches.sh
	bash backport_patches.sh

	if [ "$KERNEL" -lt 5 ] && [ "$PATCHLEVEL" -lt 14 ]; then
		bash extra_patches.sh
	fi
elif [ "$HOOK_MODE" == "ksu" ]; then
	bash backport_patches.sh
elif [ "$HOOK_MODE" == "kernel" ]; then
	bash normal_patches.sh

	if [ $KERNEL -lt 5 ] && [ $PATCHLEVEL -lt 14 ]; then
		bash extra_patches.sh
	fi
else
	echo "Doesn't exec any scripts."
fi

kernelsu(){
curl -LSs "https://raw.githubusercontent.com/$KERNELSU_AUTHOR/$KERNELSU_SETUP/refs/heads/next/kernel/setup.sh" | bash -s $KERNELSU_BRANCH
}

kernelsu_change(){
rm -rf KernelSU && rm -rf KernelSU-Next
git clone https://github.com/$KERNELSU_AUTHOR/$KERNELSU_SETUP.git -b $KERNELSU_BRANCH
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
elif [ $MODE == 4 ]; then
	echo "======================"
	echo "=                    ="
	echo "=  Change KernelSU   ="
	echo "=                    ="
	echo "======================"
	echo "  Please waiting 2s.  "
	sleep 2s
	kernelsu_change
fi
