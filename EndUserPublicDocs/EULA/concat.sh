cat EULA-EN.md; echo -e "\n\n------------------\n"; 
for file in EULA-CHS.md EULA-CHT.md EULA-JA.md; do cat "$file"; echo -e "\n\n------------------\n"; done > _concatResult.txt
