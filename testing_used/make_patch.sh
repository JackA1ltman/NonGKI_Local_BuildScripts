#!/usr/bin/env bash
need_file=(
    include/linux/uaccess.h
    mm/maccess.c
)

NUM=0
touch all_patch.patch
for i in "${need_file[@]}"; do
    let NUM++
    diff -u -p -r -N -x '*.orig' -x '*.rej' --label a/$i $i --label b/$i $i.orig > $NUM.patch
    cat "$NUM.patch" >> "all_patch.patch"
    rm $NUM.patch
done
