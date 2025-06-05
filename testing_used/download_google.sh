#!/usr/bin/env bash
need_file=(
    include/linux/set_memory.h
    arch/arm/include/asm/set_memory.h
    arch/arm64/include/asm/set_memory.h
)

export all_proxy=http://127.0.0.1:2080

for i in "${need_file[@]}"; do
    curl https://android.googlesource.com/kernel/common/+/refs/heads/deprecated/android-5.4-stable/$i -o $i --create-dirs
done
