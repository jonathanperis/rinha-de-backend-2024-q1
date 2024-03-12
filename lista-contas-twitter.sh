#!/usr/bin/env bash

arquivos=$(find . -type f -name "README.md" ! -path "./participantes/README.md") 
# echo $arquivos

for arquivo in $arquivos; do   
    urls=$(grep -o -E 'https://twitter.com[^/)]+' "$arquivo")  
    echo $urls

    if [ -n "$urls" ]; then  
        echo "$urls" 
    fi 
done | sort -u