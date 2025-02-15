#!/bin/bash
if [ -z "$1" ]; then
	MODE=1
else
	MODE=$1
fi

# Basic Var
IMAGE_DIR="$(pwd)/out/arch/arm64/boot"
TIME=$(date +"%Y%m%d%H%M%S")
CURRENT_FOLDER=$(basename "$(pwd)")
USER_HOME=/home/jackaltman/Kernel_Compile

# Compiler Var
CLANG_SELECT=los_clang_12
PATH=$USER_HOME/Clang/$CLANG_SELECT/bin:$PATH
GCC_64=CROSS_COMPILE=$USER_HOME/Gcc/gcc-64/bin/aarch64-linux-android-
GCC_32=CROSS_COMPILE_ARM32=$USER_HOME/Gcc/gcc-32/bin/arm-linux-androideabi-
CLANG_OTHER=CLANG_TRIPLE=aarch64-linux-gnu-
COMPILER_OPTION=LD=ld.lld
COMPILER_ARCH=ARCH=arm64
COMPILER_OUT=O=out
COMPILER_DEFCONFIG=custom-polaris_defconfig

build(){
make mrproper && rm -f error.log
make $COMPILER_OUT $COMPILER_ARCH $COMPILER_DEFCONFIG
make -j$(nproc --all) CC="ccache clang" $COMPILER_OUT $COMPILER_ARCH $COMPILER_OPTION $CLANG_OTHER $GCC_64 $GCC_32 2>&1|tee error.log
}

anykernel3(){
# AnyKernel3 Var
AK3_LOCATION="$(pwd)/Anykernel3"

mkdir -p tmp
cp -fp $IMAGE_DIR/Image.gz tmp
cp -fp $IMAGE_DIR/dtbo.img tmp
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
cp -fp tmp/tmp.zip XTD-OPKona-$TIME.zip
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
	echo "=   Exec the command   ="
	echo "=                      ="
	echo "========================"
	#echo "mkbootimg/mkbootimg.py $FORMAT_MKBOOTIMG -o /home/jackaltman/Kernel_Compile/Compiled_Kernel/boot_${CURRENT_FOLDER}_${TIME}.img"
	echo "========================"
        echo "= Compile Successfully ="
        echo "========================"
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
else
	echo "======================"
	echo "=                    ="
	echo "=  Execution Error!  ="
	echo "=                    ="
	echo "======================"
	echo "        Exit !        "
	exit
fi
