#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

exts=(cmp uncmp)
for ext in "${exts[@]}"; do
    nb_points=$(cat res/*.$ext | wc -l)

    hull=$((
    echo 2
    echo "$nb_points"
    cat res/*.$ext | cut -d- -f1
    ) | qconvex p | tail -n +3 | sort -n)

    echo "$hull" > hull
    for file in res/*.$ext; do
        best=$(join -t- -j1 <(sort -n "$file") <(echo "$hull"))
        echo "$best" > $file
    done
done
