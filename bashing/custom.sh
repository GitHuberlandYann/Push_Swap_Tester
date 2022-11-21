#!/bin/sh

PURPLE='\033[0;35m'
RED='\033[0;31m'
GREEN='\033[0;32m'
BRED='\033[1;31m'
BGREEN='\033[1;32m'
NC='\033[0m' # No Color

if [ $# -le 1 ]
then
	make
	make bonus
	
	value=5
	for i in 1 2 3 4 5
	do
		if [ $# -eq 1 ]
		then
			NBR_TESTS=$1
		else
			NBR_TESTS=5 #default value
		fi

		echo "Test $i with ${PURPLE}$value${NC} numbers"
		while [ $NBR_TESTS -ge 1 ]
		do
			ARG=`ruby -e "puts (1..$value).to_a.shuffle.join(' ')"`
			INS=$(./push_swap $ARG)
			if [ ! "$INS" = "" ] ; then
				INS="$INS\n"
			fi
			NBR=$(printf "$INS" | wc -l)
			RES=$(printf "$INS" | ./checker $ARG)
			if [ "$RES" = "KO" ]
				then
					echo "\t$NBR -> ${RED}$RES${NC}\n\tyour program failed to sort $ARG"
				else
					echo "\t$NBR -> ${GREEN}$RES${NC}"
				fi
			NBR_TESTS=$((NBR_TESTS-1))
		done
		if [ $(( i % 2 )) != 0 ]
		then
			value=$((value * 2))
		else
			value=$((value * 5))
		fi
	done
elif [ $# -eq 2 ]
then
	make
	make bonus
	NBR_TESTS=$1
	if [ $1 -ge 2 ]
	then
		echo "${PURPLE}$1${NC} tests with ${PURPLE}$2${NC} numbers"
	else
		echo "${PURPLE}$1${NC} test with ${PURPLE}$2${NC} numbers"
	fi
	MIN="6000"
	MAX="0"
	while [ $NBR_TESTS -ge 1 ]
	do
		ARG=`ruby -e "puts (1..$2).to_a.shuffle.join(' ')"`
		INS=$(./push_swap $ARG)
        if [ ! "$INS" = "" ] ; then
            INS="$INS\n"
        fi
        NBR=$(printf "$INS" | wc -l)
        RES=$(printf "$INS" | ./checker $ARG)
		if [ "$RES" = "KO" ]
		then
			echo "\t$NBR -> ${RED}$RES${NC}"
			echo "\tyour program failed to sort $ARG"
		else
			echo "\t$NBR -> ${GREEN}$RES${NC}"
		fi

		if [ $MIN -ge $NBR ]
		then
			MIN=$NBR
			MIN_ARG=$ARG
		fi
		if [ $MAX -le $NBR ]
		then
			MAX=$NBR
			MAX_ARG=$ARG
		fi
		NBR_TESTS=$((NBR_TESTS-1))
	done
	echo "${BGREEN}best${NC}  : $MIN\t\twith $MIN_ARG"
	if [ $1 -ge 2 ]
	then
		echo "${RED}worst${NC} : $MAX\t\twith $MAX_ARG"
	fi
else
	echo "wrong nbr of args."
fi