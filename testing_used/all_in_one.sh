#!/usr/bin/env bash
#Need Files
need_file=(
drivers/android/binder_alloc.c
drivers/android/binder.c
kernel/signal.c
)

#Set Proxy
export all_proxy=http://127.0.0.1:2080

#Env
SHELL_OPTION=$1
ROM_TEXT='Evolution-X-Devices/kernel_xiaomi_sdm845'
ROM_BRANCH='vic'
PATCH_FILE='binder_freezer_to_49.patch'

getOriginFile(){
for i in "${need_file[@]}"; do
    curl https://raw.githubusercontent.com/$ROM_TEXT/refs/heads/$ROM_BRANCH/$i -o $i --create-dirs
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

if [ "$SHELL_OPTION" == "1" ]; then
    echo "getOriginFile"
    getOriginFile
elif [ "$SHELL_OPTION" == "2" ]; then
    echo "makePatchFile"
    makePatchFile
elif [ "$SHELL_OPTION" == "3" ]; then
    echo "outPatchFile"
    outPatchFile
fi
