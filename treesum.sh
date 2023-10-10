#!/bin/bash

RED='\033[01;31m'
GREEN='\033[01;32m'
BLUE='\033[01;34m'
YELLOW='\033[01;33m'
NC='\033[0m'

declare -i depth=-1
declare -i max=0
declare -i scale=20
declare -i all=0
declare -i allsize=0
declare -i nosize=0
usage() { echo "Usage: $0 [-d <dir>] [-p <depth>] [-m <uppersize>] [-s <sizescale>] [-a] [-n] [-o]" 1>&2; exit 1; }

while getopts ":d::p:m:s:ahno" o; do
    case "${o}" in
        d)
            repo=${OPTARG} #Directory, if empty use current (default)
            ;;
        p)
            depth=${OPTARG} #Depth of the file tree, if negative go all the way down (default)
            ;;
        m)
            max=${OPTARG} #Upper size limit of color scale, defaults to max size found
            ;;
        s)
            scale=${OPTARG} #Scale for color scale, defaults to 20
            ;;
        a)
            all=1 #Not only show folders but also files
            ;;
        n)
            nosize=1 #Do not display sizes (unix 'tree' is much faster)
            ;;
        o)
            allsize=1 #Show very small sizes instead of '< lowest'
            ;;
        h | *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ ! -z "${repo}" ] && [ ! -d "${repo}" ];then
    echo "Folder ${repo} does not exist"
    exit 1
fi

if [ "${max}" -lt 0 ];then
    echo "Invalid upper size limit of $max, must be >= 0"
    exit 1
fi

if [ "${scale}" -lt 3 ];then
    echo "Invalid scale of $scale, must be >= 3"
    exit 1
fi

cmddu='du --block-size=1'
cmdf='find'
if [ ! -z "${repo}" ];then
    cmddu=$cmddu' '"${repo}"
    cmdf=$cmdf' '"${repo}"
else
    cmddu=$cmddu' .'
fi

if [ "${depth}" -ge 0 ]; then
    cmddu=$cmddu' -d '"$depth"
    cmdf=$cmdf' -maxdepth '"$depth"
fi

if [ "${all}" -eq 1 ]; then
    cmddu=$cmddu' -a'
else    
    cmdf=$cmdf' -type d'
fi

if [ "${nosize}" -eq 1 ];then
    htree=$(echo "`$cmdf`")
    dirtree=$(echo "$htree")
    max=0
    sizetree=""
else
    htree=$(echo "`$cmddu`")
    dirtree=$(echo "$htree" | cut -f2 | tac)
    if [ "$max" -eq 0 ]; then
        max=$(echo "$htree" | cut -f1 | sort -nr | head -n2 | tail -n1)
    fi
    sizetree=$(paste <(echo "$htree") <(echo "$htree" | cut -f1 | numfmt --to=iec --suffix=B --format="%3f"))
fi


hig=$(($max-$max/$scale))
low=$(($max/$scale))
med=$(($max/2))

if [ "${allsize}" -eq 0 ];then
    lowhuman=$(echo "<$(numfmt --to=iec --suffix=B --format="%3f" $low)")
    newsizetree=$(awk -F $'\t' -v OFS=$'\t' -v lh="$lowhuman" '$1 < '"$low"' { $3 = lh } { print ($1,$2,$3) }' <(echo "$sizetree"))
    sizetree="$newsizetree"
fi

echo "$dirtree" | \
sed -r 's/(.*)([^\/]+\/){1}/\1\/'$(printf "\x1b(0\x6d\x1b(B\x1b(0\x71\x1b(B\x1b(0\x71\x1b(B")'\\ /g' | \
sed -r 's/[^\/]+\/{1}/\t/g' | \
sed -r 's/\/{1}//g' | \
sed -r 's/(\\ (\s|\S){18})((\S|\s)+)((\S|\s){3}$)/\1(..)\5/g' | \
paste - <(echo "$sizetree" | tac | awk -F $'\t' -v r=$RED -v y=$YELLOW -v g=$GREEN -v b=$BLUE -v n=$NC \
    '$1 >= '"$hig"' { print r"["$3"]"n;next } $1 >= '"$med"' { print y"["$3"]"n;next } \
    $1 >= '"$low"' { print g"["$3"]"n;next } $1 < '"$low"' { print b"["$3"]"n;next }')

