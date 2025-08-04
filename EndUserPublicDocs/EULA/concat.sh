# 清空或创建输出文件
> _concatResult.md

# 拼接 EULA-EN.md
if [[ -f EULA-EN.md ]]; then
    cat EULA-EN.md >> _concatResult.md
    echo -e "\n\n------------------\n" >> _concatResult.md
else
    echo "错误：EULA-EN.md 文件不存在" >&2
    exit 1
fi

# 拼接其他语言的 EULA 文件
for file in EULA-CHS.md EULA-CHT.md EULA-JA.md; do
    if [[ -f "$file" ]]; then
        cat "$file" >> _concatResult.md
        echo -e "\n\n------------------\n" >> _concatResult.md
    else
        echo "错误：$file 文件不存在" >&2
        exit 1
    fi
done