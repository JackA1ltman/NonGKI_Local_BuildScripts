#!/bin/bash
if [ -z "$1" ]; then
	echo "Currently, no selection has been made, defaulting to Mode 1."
	MODE=1
else
	MODE=$1
fi

# Basic Var
IMAGE_DIR="$(pwd)/out/arch/arm64/boot"
TIME=$(date +"%Y%m%d%H%M%S")
CURRENT_FOLDER=$(basename "$(pwd)")
USER_HOME=/home/jackaltman/Kernel_Build

# Compiler Var
CLANG_SELECT=clang-r428724
PATH=$USER_HOME/Old_toolchain/clang/host/linux-x86/$CLANG_SELECT/bin:$PATH
GCC_64=CROSS_COMPILE=$USER_HOME/Old_toolchain/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin/aarch64-linux-android-
GCC_32=CROSS_COMPILE_ARM32=$USER_HOME/Old_toolchain/gcc/linux-x86/arm/arm-linux-androideabi-4.9/bin/arm-linux-androideabi-
#GCC_64=CROSS_COMPILE=aarch64-linux-gnu-
#GCC_32=CROSS_COMPILE_ARM32=arm-none-eabi-
CLANG_OTHER=CLANG_TRIPLE=aarch64-linux-gnu-
COMPILER_OPTION='DTC_EXT=dtc SUBARCH=arm64 LLVM=1 LLVM_IAS=1 AR=llvm-ar NM=llvm-nm OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump READELF=llvm-readelf OBJSIZE=llvm-size STRIP=llvm-strip HOSTCC=clang HOSTCXX=clang++ LLVM_AR=llvm-ar LLVM_DIS=llvm-dis CONFIG_NO_ERROR_ON_MISMATCH=y'
COMPILER_ARCH=ARCH=arm64
COMPILER_OUT=O=out
COMPILER_DEFCONFIG=dipper_user_defconfig

build(){
make mrproper && rm -f error.log
make $COMPILER_OUT $COMPILER_ARCH  $COMPILER_OPTION $GCC_64 $GCC_32 $COMPILER_DEFCONFIG
make -j$(nproc --all) $COMPILER_OUT $COMPILER_ARCH $COMPILER_OPTION $GCC_64 $GCC_32 2>&1|tee error.log
}

anykernel3(){
# AnyKernel3 Var
AK3_LOCATION="$(pwd)/AnyKernel3"

mkdir -p tmp
cp -fp $IMAGE_DIR/Image.gz-dtb tmp
#cp -fp $IMAGE_DIR/dtbo.img tmp
if [ -f "$IMAGE_DIR/dtb" ]; then
	echo "Found DTB!"
	cp -fp $IMAGE_DIR/dtb tmp
else
	echo "Doesn't found DTB! u device maybe needn't the file."
fi
cp -rp $AK3_LOCATION/* tmp
cd tmp
7za a -mx9 tmp.zip *
cd ..
rm *.zip
cp -fp tmp/tmp.zip Xiaomi8-$TIME.zip
rm -rf tmp
}

mkbootimg(){
# MKBOOTIMG Var
FORMAT_MKBOOTIMG=$(echo `$USER_HOME/mkbootimg/unpack_bootimg.py --boot_img=$USER_HOME/KernelSourceIMGs/boot_$CURRENT_FOLDER.img --out outKernel --format mkbootimg`)
IMAGE_MKBOOTIMG=Image.gz-dtb

if [ $? -eq 0 ]; then
        if [ -f "outKernel" ]; then
        	mkdir outKernel
        fi
        rm -f outKernel/*
        $USER_HOME/mkbootimg/unpack_bootimg.py --boot_img $USER_HOME/KernelSourceIMGs/boot_$CURRENT_FOLDER.img --out outKernel
	cp $IMAGE_DIR/$IMAGE_MKBOOTIMG outKernel/kernel
	$USER_HOME/mkbootimg/mkbootimg.py --kernel outKernel/kernel --ramdisk outKernel/ramdisk $FORMAT_MKBOOTING -o boot_${CURRENT_FOLDER}_${TIME}.img
	echo "========================"
	echo "=                      ="
	echo "= Compile Successfully ="
	echo "=                      ="
	echo "========================"
	echo "$(ls boot_${CURRENT_FOLDER}_${TIME}.img)"
else
        echo "Compile Failed!Please check error.log."
fi
}

if [ $MODE == 1 ]; then
	echo "======================"
	echo "=                    ="
	echo "=  Execution Mode 1  ="
	echo "=                    ="
	echo "======================"
	echo "  Please waiting 5s.  "
	sleep 5s
	build
	anykernel3
elif [ $MODE == 2 ]; then
	echo "======================"
	echo "=                    ="
	echo "=  Execution Mode 2  ="
	echo "=                    ="
	echo "======================"
	echo "  Please waiting 5s.  "
	sleep 5s
	build
	mkbootimg
elif [ $MODE == 3 ]; then
	echo "======================"
	echo "=                    ="
	echo "=Execution Mode Build="
	echo "=                    ="
	echo "======================"
	echo "  Please waiting 2s.  "
	build
elif [ $MODE == 4 ]; then
	echo "======================"
	echo "=                    ="
	echo "=     Anykernel3     ="
	echo "=                    ="
	echo "======================"
	echo "  Please waiting 5s.  "
	sleep 5s
	anykernel3
else
	echo "======================"
	echo "=                    ="
	echo "=  Execution Error!  ="
	echo "=                    ="
	echo "======================"
	echo "        Exit !        "
	exit
fi
