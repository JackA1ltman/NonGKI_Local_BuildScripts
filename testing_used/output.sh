#!/usr/bin/env bash

patch_file="4_19_susfs_upgrade_to_157.patch"  # 替换成你的 patch 文件路径
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
