# 清空或创建输出文件
> _concatResult.md

# 拼接 PRIVACY_POLICY-EN.md
if [[ -f PRIVACY_POLICY-EN.md ]]; then
    cat PRIVACY_POLICY-EN.md >> _concatResult.md
    echo -e "\n\n------------------\n" >> _concatResult.md
else
    echo "错误：PRIVACY_POLICY-EN.md 文件不存在" >&2
    exit 1
fi

# 拼接其他语言的 PRIVACY_POLICY 文件
for file in PRIVACY_POLICY-CHS.md PRIVACY_POLICY-CHT.md PRIVACY_POLICY-JA.md; do
    if [[ -f "$file" ]]; then
        cat "$file" >> _concatResult.md
        echo -e "\n\n------------------\n" >> _concatResult.md
    else
        echo "错误：$file 文件不存在" >&2
        exit 1
    fi
done