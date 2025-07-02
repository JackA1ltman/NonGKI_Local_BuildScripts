#!/usr/bin/env bash
#Need Files
need_file=(
fs/namespace.c
include/linux/sched.h
Makefile
)

#Set Proxy
export all_proxy=http://127.0.0.1:2080

#Env
SHELL_OPTION=$1
ROM_TEXT='EndCredits/android_kernel_xiaomi_sm8350-miui'
ROM_BRANCH='hyper-14'
PATCH_FILE='50_add_susfs_in_kernel-4.9.patch'
PATCH_LINK="https://github.com/AOSP-msm8998/kernel_xiaomi_msm8998/commit/e8c6cac2a1235d608ef2f50b318a241b763ce939"

getOriginFile(){
for i in "${need_file[@]}"; do
    curl https://raw.githubusercontent.com/$ROM_TEXT/refs/heads/$ROM_BRANCH/$i -o $i --create-dirs --retry 3
    cp $i $i.orig
done
}

makePatchFile(){
NUM=0
touch all_patch.patch
for i in "${need_file[@]}"; do
    let NUM++
    diff -u -p -r -N -x '*.orig' -x '*.rej' --label a/$i $i --label b/$i $i.orig > $NUM.patch
    cat "$NUM.patch" >> "all_patch.patch"
    rm $NUM.patch
done
}

outPatchFile(){
patch_file=$PATCH_FILE  # 替换成你的 patch 文件路径
declare -a files=()

while IFS= read -r line; do
    if [[ $line =~ ^\+\+\+[[:space:]]+[ab]/(.+) ]]; then
        file="${BASH_REMATCH[1]}"
        # 忽略 /dev/null
        if [[ "$file" != "/dev/null" ]]; then
            files+=("$file")
        fi
    fi
done < "$patch_file"

# 去重（可选）
unique_files=($(printf "%s\n" "${files[@]}" | sort -u))

# 输出数组（形式为数组的格式）
echo "文件数组如下："
for f in "${unique_files[@]}"; do
    echo "$f"
done
}

removeTrashFile(){
for i in "${need_file[@]}"; do
    echo $i
    rm -f $i
done
}

getOriginFileGoogle(){
for i in "${need_file[@]}"; do
    curl https://android.googlesource.com/kernel/common/+/refs/heads/deprecated/android-5.4-stable/$i -o $i --create-dirs
done
}

autoExecPatchFile(){
curl -LSs "$PATCH_LINK.patch" -o kernel.patch
patch -p1 < kernel.patch
rm -f kernel.patch
}

if [ "$SHELL_OPTION" == "1" ]; then
    echo "getOriginFile"
    getOriginFile
elif [ "$SHELL_OPTION" == "2" ]; then
    echo "makePatchFile"
    makePatchFile
elif [ "$SHELL_OPTION" == "3" ]; then
    echo "outPatchFile"
    outPatchFile
elif [ "$SHELL_OPTION" == "4" ]; then
    echo "removeTrashFile"
    removeTrashFile
elif [ "$SHELL_OPTION" == "5" ]; then
    echo "getOriginFileGoogle"
    getOriginFileGoogle
elif [ "$SHELL_OPTION" == "6" ]; then
    echo "autoExecPatchFile"
    autoExecPatchFile
fi
