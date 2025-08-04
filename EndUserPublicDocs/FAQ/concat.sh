# 清空或创建输出文件
> _concatResult.md

# 拼接 FAQ-EN.md
if [[ -f FAQ-EN.md ]]; then
    cat FAQ-EN.md >> _concatResult.md
    echo -e "\n\n------------------\n" >> _concatResult.md
else
    echo "错误：FAQ-EN.md 文件不存在" >&2
    exit 1
fi

# 拼接其他语言的 FAQ 文件
for file in FAQ-CHS.md FAQ-CHT.md FAQ-JA.md; do
    if [[ -f "$file" ]]; then
        cat "$file" >> _concatResult.md
        echo -e "\n\n------------------\n" >> _concatResult.md
    else
        echo "错误：$file 文件不存在" >&2
        exit 1
    fi
done