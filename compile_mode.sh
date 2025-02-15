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
USER_HOME=/home/jackaltman

# Compiler Var
CLANG_SELECT=los_clang_12
PATH=$USER_HOME/Kernel_Compile/Clang/$CLANG_SELECT/bin:$PATH
GCC_64=CROSS_COMPILE=$USER_HOME/Kernel_Compile/Gcc/gcc-64/bin/aarch64-linux-android-
GCC_32=CROSS_COMPILE_ARM32=$USER_HOME/Kernel_Compile/Gcc/gcc-32/bin/arm-linux-androideabi-
CLANG_OTHER=CLANG_TRIPLE=aarch64-linux-gnu-
COMPILER_OPTION=LD=ld.lld
COMPILER_ARCH=ARCH=arm64
COMPILER_OUT=O=out
COMPILER_DEFCONFIG=vendor/kona-perf_defconfig

build(){
make mrproper && rm -f error.log
make $COMPILER_OUT $COMPILER_ARCH $COMPILER_DEFCONFIG
make -j$(nproc --all) CC="ccache clang" $COMPILER_OUT $COMPILER_ARCH $COMPILER_OPTION $CLANG_OTHER $GCC_64 $GCC_32 2>&1|tee error.log
}

anykernel3(){
mkdir -p tmp
cp -fp $IMAGE_DIR/Image.gz tmp
cp -fp $IMAGE_DIR/dtbo.img tmp
if [ -f "$IMAGE_DIR/dtb" ]; then
	echo "Found DTB!"
	cp -fp $IMAGE_DIR/dtb tmp
else
	echo "Doesn't found DTB! u device maybe needn't the file."
fi
cp -rp Anykernel3/* tmp
cd tmp
7za a -mx9 tmp.zip *
cd ..
rm *.zip
cp -fp tmp/tmp.zip XTD-OPKona-$TIME.zip
rm -rf tmp
}

mkbootimg(){
if [ $? -eq 0 ]; then
        sed -i 's/^ROM_CURRENT=[^ ]*/ROM_CURRENT='$CURRENT_FOLDER'/' $USER_HOME/Kernel_Compile/generate.sh
        cd $USER_HOME/Kernel_Compile/
        bash generate.sh
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
