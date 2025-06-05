#!/usr/bin/env bash
LINK="https://github.com/AOSP-msm8998/kernel_xiaomi_msm8998/commit/e8c6cac2a1235d608ef2f50b318a241b763ce939"
curl -LSs "$LINK.patch" -o kernel.patch
patch -p1 < kernel.patch
rm -f kernel.patch
