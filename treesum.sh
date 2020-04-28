#!/bin/bash

RED='\033[01;31m'
GREEN='\033[01;32m'
BLUE='\033[01;34m'
YELLOW='\033[01;33m'
NC='\033[0m'

hig=100000
usage() { echo "Usage: $0 [-d <dir>] [-p <int>] [-m <int>] [-a] [-n]" 1>&2; exit 1; }

while getopts ":d::p:m:ahn" o; do
    case "${o}" in
    	d)
            repo=${OPTARG}
            ;;
        p)
            depth=${OPTARG}
            ;;
        m)
            hig=${OPTARG}
            ;;
        a)
            all=1
            ;;
        n)
            nosize=1
            ;;
        h | *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

cmddu='du'
cmdf='find'
if [ ! -z "${repo}" ] && [ -d "${repo}" ];then
	cmddu=$cmddu' '"${repo}"
	cmdduh=$cmddu' '"${repo}"' -h'
	cmdf=$cmdf' '"${repo}"
else
	cmddu=$cmddu' .'
	cmdduh=$cmddu' . -h'
fi

if [ ! -z "${depth}" ] && [ "$depth" -eq "$depth" ]; then
    cmddu=$cmddu' -d '"$depth"
    cmdduh=$cmdduh' -d '"$depth"
    cmdf=$cmdf' -maxdepth '"$depth"
fi

if [ "$hig" -eq "$hig" ]; then
    med=$(($hig/2))
    low=$(($hig/10))
fi

if [ ! -z "${all}" ]; then
    cmddu=$cmddu' -a'
    cmdduh=$cmdduh' -a'
else	
    cmdf=$cmdf' -type d'
fi

if [ ! -z "${nosize}" ];then
	htree=$(echo "`$cmdf`")
	dirtree=$(echo "$htree")
	sizetree=""
else
	htree=$(echo "`$cmdduh`")
	dirtree=$(echo "$htree" | cut -f2 | tac)
	sizetree=$(echo "$htree" | cut -f1 | paste - <(echo "`$cmddu`") | tac)
fi

echo "$dirtree" | \
sed -r 's/(.*)([^\/]+\/){1}/\1\/'$(printf "\x1b(0\x6d\x1b(B\x1b(0\x71\x1b(B\x1b(0\x71\x1b(B")' /g' | \
sed -r 's/[^\/]+\/{1}/\t/g' | \
sed -r 's/^\/{1}//g' | \
paste - <(echo "$sizetree" | awk -v r=$RED -v y=$YELLOW -v g=$GREEN -v b=$BLUE -v n=$NC \
	'$2 > '"$hig"' { print r"["$1"]"n;next } $2 >= '"$med"' { print y"["$1"]"n;next } \
	$2 >= '"$low"' { print g"["$1"]"n;next } $2 < '"$low"' { print b$1n;next }')
