cat FAQ-EN.md; echo -e "\n\n------------------\n"; 
for file in FAQ-CHS.md FAQ-CHT.md FAQ-JA.md; do cat "$file"; echo -e "\n\n------------------\n"; done > _concatResult.txt
