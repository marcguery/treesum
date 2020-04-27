#!/bin/bash

RED='\033[01;31m'
GREEN='\033[01;32m'
BLUE='\033[01;34m'
YELLOW='\033[01;33m'
NC='\033[0m'
HIG=100000
MED=50000
LOW=10000

usage() { echo "Usage: $0 [-d <int>] [-a]" 1>&2; exit 1; }

while getopts ":d:ah" o; do
    case "${o}" in
        d)
            depth=${OPTARG}
            ;;
        a)
            all=1
            ;;
        h | *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

cmdduh='du -h'
cmddu='du'
if [ -n "${depth}" ]; then
    cmdduh=$cmdduh' -d '"$depth"
    cmddu=$cmddu' -d '"$depth"
fi

if [ -n "${all}" ]; then
    cmdduh=$cmdduh' -a'
    cmddu=$cmddu' -a'
fi

htree=$(echo "`$cmdduh`")
dirtree=$(echo "$htree" | cut -f2 | tac)
sizetree=$(echo "$htree" | cut -f1 | paste - <(echo "`$cmddu`") | tac)

echo "$dirtree" | \
sed -r 's/(.*)([^\/]+\/){1}/\1\t/g' | \
sed -r 's/\t/a\/'$(printf "\x1b(0\x6d\x1b(B\x1b(0\x71\x1b(B\x1b(0\x71\x1b(B")'/g' | \
sed -r 's/[^\/]+\/{1}/\t/g' | \
sed -r 's/^\t{1}//g' | \
paste - <(echo "$sizetree" | awk -v r=$RED -v y=$YELLOW -v g=$GREEN -v b=$BLUE -v n=$NC \
	'$2 > '"$HIG"' { print r"["$1"]"n;next } $2 >= '"$MED"' { print y"["$1"]"n;next } \
	$2 >= '"$LOW"' { print g"["$1"]"n;next } $2 < '"$LOW"' { print b$1n;next }')
