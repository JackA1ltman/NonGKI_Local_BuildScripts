#!/usr/bin/env bash
need_file=(
    include/linux/uaccess.h
    mm/maccess.c
)

for i in "${need_file[@]}"; do
    echo $i
    rm -f $i
done
