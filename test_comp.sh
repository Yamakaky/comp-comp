#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

export LC_ALL="en_US.UTF-8"
export TIMEFORMAT="%R"

dir=$(mktemp -d)

function finish {
    cd
    rm -rf "$dir"
}
trap finish EXIT

function comp_gz {
    in=$1
    out=$2
    comp_level=$3
    gzip -fk "$in" "$comp_level" > "$out"
}

function uncomp_gz {
    in=$1
    out=$2
    comp_level=$3
    gunzip -fk "$in" "$comp_level" > "$out"
}

function comp_zip {
    in=$1
    out=$2
    comp_level=$3
    zip --quiet "$out" "$in" "$comp_level"
}

function uncomp_zip {
    in=$1
    out=$2
    comp_level=$3
    unzip -q "$in" -d "$out"
}

function comp_lzip {
    in=$1
    out=$2
    comp_level=$3
    lzip -kc "$in" "$comp_level" > "$out"
}

function uncomp_lzip {
    in=$1
    out=$2
    comp_level=$3
    lzip -dkc "$in" "$comp_level" > "$out"
}

function comp_xz {
    in=$1
    out=$2
    comp_level=$3
    xz -kc "$in" "$comp_level" > "$out"
}

function uncomp_xz {
    in=$1
    out=$2
    comp_level=$3
    unxz -kc "$in" "$comp_level" > "$out"
}

function comp_bz2 {
    in=$1
    out=$2
    comp_level=$3
    bzip2 -kc "$in" "$comp_level" > "$out"
}

function uncomp_bz2 {
    in=$1
    out=$2
    comp_level=$3
    bunzip2 -kc "$in" "$comp_level" > "$out"
}

function hull_calculation {
    exts=(cmp uncmp)
    for ext in "${exts[@]}"; do
        nb_points=$(cat res/*.$ext | wc -l)

        hull=$((
            echo 2
            echo "$nb_points"
            cat res/*.$ext | cut -d- -f1
        ) | qconvex p \
          | tail -n +3 \
          | sed -re 's/^ *([^ ]+) *([^ ]+) *$/\1 \2 /' \
          | sort -n)

        echo "$hull"
        for file in res/*.$ext; do
            best=$(join -t- -j1 <(sort -n "$file") <(echo "$hull"))
            echo "$best" > $file
        done
    done
}

function size {
    wc -c $1 | cut -d' ' -f 1
}

function main {
    algos=("zip" "gz" "lzip" "xz" "bz2")
    #algos=("zip" "bz2")
    rm -rf res
    mkdir -p res

    for src_file in *.tar; do
        echo "$src_file" >&2
        file="$dir/$src_file"
        cp "$src_file" "$file"
        size_uncmp=$(size "$file")
        for algo in ${algos[@]}; do
            echo "  $algo" >&2
            for speed in $(seq 1 9); do
                echo "    -$speed" >&2
                time_cmp=$((time comp_$algo "$file" "$file.$algo" "-$speed") 2>&1)
                size_cmp=$(size "$file.$algo")
                time_uncmp=$((time uncomp_$algo "$file.$algo" "$file.uncmp" "-$speed") 2>&1)
                dif=$(echo "scale=3; $size_uncmp / $size_cmp" | bc)
                echo "$time_cmp $dif -$speed" >> res/$algo.cmp
                echo "$time_uncmp $dif -$speed" >> res/$algo.uncmp
                rm -rf "$file.$algo" "$file.uncmp"
            done
        done
        rm -f "$file"
    done

    hull_calculation
}

main
