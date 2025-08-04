cat PRIVACY_POLICY-EN.md; echo -e "\n\n------------------\n"; 
for file in PRIVACY_POLICY-CHS.md PRIVACY_POLICY-CHT.md PRIVACY_POLICY-JA.md; do cat "$file"; echo -e "\n\n------------------\n"; done > _concatResult.txt
