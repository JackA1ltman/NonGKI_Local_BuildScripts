#!/bin/sh
cd /home/jackaltman/Kernel_Compile
rm -f out/*
ROM_CURRENT=evox_a15_mix2s
TIME=$(echo `date +%Y%m%d`)
FORMAT_MKBOOTING=$(echo `mkbootimg/unpack_bootimg.py --boot_img=KernelSourceIMGs/boot_$ROM_CURRENT.img --format mkbootimg`)
mkbootimg/unpack_bootimg.py --boot_img /home/jackaltman/Kernel_Compile/KernelSourceIMGs/boot_$ROM_CURRENT.img
cp Kernel/$ROM_CURRENT/out/arch/arm64/boot/Image.gz-dtb out/kernel
#mkbootimg/mkbootimg.py $FORMAT_MKBOOTING -o /home/ubuntu/out/boot.img
echo "========================"
echo "=                      ="
echo "=   Exec the command   ="
echo "=                      ="
echo "========================"
echo "mkbootimg/mkbootimg.py $FORMAT_MKBOOTING -o /home/jackaltman/Kernel_Compile/Compiled_Kernel/boot_${ROM_CURRENT}_${TIME}.img"
echo "========================"
