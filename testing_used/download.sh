#!/usr/bin/env bash
need_file=(
    include/linux/uaccess.h
    mm/maccess.c
)

export all_proxy=http://127.0.0.1:2080
ROM_TEXT='JackA1ltman/kernel_blackshark_penrose'
ROM_BRANCH='penrose-r-oss'

for i in "${need_file[@]}"; do
    curl https://raw.githubusercontent.com/$ROM_TEXT/refs/heads/$ROM_BRANCH/$i -o $i --create-dirs
    cp $i $i.orig
done
