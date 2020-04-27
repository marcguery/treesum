DEPTH=$1
RED='\033[01;31m'
GREEN='\033[01;32m'
BLUE='\033[01;34m'
YELLOW='\033[01;33m'
NC='\033[0m'
if [ -z ${DEPTH} ];then
	dirtree=$(du -a -h | cut -f2 | tac)
	sizetree=$(du -a -h | cut -f1 | paste - <(du -a) | tac)
else
	dirtree=$(du -a -h -d "$DEPTH" | cut -f2 | tac)
	sizetree=$(du -a -h -d "$DEPTH" | cut -f1 | paste - <(du -a -d "$DEPTH") | tac)
fi

echo "$dirtree" | \
sed -r 's/\.\//\t/g' | \
sed -r 's/(([^(\/|\t)])+\/){1}/  |____/g' | \
sed -r 's/\.$/('"$(basename $PWD)"')/g' | \
paste - <(echo "$sizetree" | awk -v r=$RED -v y=$YELLOW -v g=$GREEN -v b=$BLUE -v n=$NC \
	'$2 > 100000 { print r$1n;next } $2 >= 50000 { print y$1n;next } \
	$2 >= 10000 { print g$1n;next } $2 < 10000 { print b$1n;next }')