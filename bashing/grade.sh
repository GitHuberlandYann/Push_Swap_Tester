#!/bin/sh

PURPLE='\033[0;35m'
RED='\033[0;31m'
GREEN='\033[0;32m'
BRED='\033[1;31m'
BGREEN='\033[1;32m'
BLUE='\033[0;36m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color 34 blue 36 lightblue

make
make bonus

PUSH=./push_swap
CHECKER=./checker

#   ---- functions ----   #

grade_this()
{
    if [ $1 -eq 5 ] ; then
        if [ $2 -le 12 ] ; then
            printf "\t\t${BGREEN}[1/1]${NC}\n"
        else
            printf "\t\t${BRED}[0/1]${NC}\n"
        fi
    elif [ $1 -eq 100 ] ; then
        if [ $2 -le 700 ] ; then
            printf "\t${BGREEN}[5/5]${NC}\n"
        elif [ $2 -le 900 ] ; then
            printf "\t${GREEN}[4/5]${NC}\n"
        elif [ $2 -le 1100 ] ; then
            printf "\t${YELLOW}[3/5]${NC}\n"
        elif [ $2 -le 1300 ] ; then
            printf "\t${BLUE}[2/5]${NC}\n"
        elif [ $2 -le 1500 ] ; then
            printf "\t${RED}[1/5]${NC}\n"
        else
            printf "\t${BRED}[0/5]${NC}\n"
        fi
    elif [ $1 -eq 500 ] ; then
        if [ $2 -le 5500 ] ; then
            printf "\t${BGREEN}[5/5]${NC}\n"
        elif [ $2 -le 7000 ] ; then
            printf "\t${GREEN}[4/5]${NC}\n"
        elif [ $2 -le 8500 ] ; then
            printf "\t${YELLOW}[3/5]${NC}\n"
        elif [ $2 -le 10000 ] ; then
            printf "\t${BLUE}[2/5]${NC}\n"
        elif [ $2 -le 11500 ] ; then
            printf "\t${RED}[1/5]${NC}\n"
        else
            printf "\t${BRED}[0/5]${NC}\n"
        fi
    fi
}

printf_test()
{
    printf 'Test with %s ...' "$1"
    COUNT=1
}

display_result()
{
    if [ "$RES" = "$EXPECTED_RES" ] ; then
        printf " ${GREEN}$COUNT.OK${NC}"
    else
        printf " ${RED}$COUNT.KO${NC}"
        ERRORS="$ERRORS\tTest $COUNT : $1 returned '$RES' instead of '$EXPECTED_RES' when called with ARG='$ARG'.\n"
    fi
    COUNT=$(( COUNT + 1 ))
}

set_test()
{
    ARG=$1
    RES=$($PUSH $ARG | cat -e)
    EXPECTED_RES=$2
    display_result $PUSH
}

display_error()
{
    printf "${RED}$ERRORS${NC}"
    if [ ! "$ERRORS" = "\n" ] ; then
        ERRORS="\n"
    fi
}

#   --- main ---   #

ERRORS="\n"

printf_test "no argument"
set_test "" ""
set_test "" ""
display_error

printf_test "non numerical arguments"
set_test "0 1 2 d 3" "Error$"
set_test "text" "Error$"
set_test "0 1 2 3.5 4" "Error$"
set_test "1 * 0" "Error$"
set_test "! # $" "Error$"
set_test "0 +1 2 3" "Error$"
set_test "one two three" "Error$"
display_error

printf_test "2 identical arguments"
set_test "0 0" "Error$"
set_test "5 3 1 2 4 2" "Error$"
set_test "0 1 2 3 4 5 6 2 7 8 9 10 11" "Error$"
set_test "-8 -129 14 2147596 -129 -46" "Error$"
set_test "19 50 36 48 76 36 82 36" "Error$"
display_error

printf_test "invalid numbers"
set_test "2147483648" "Error$"
set_test "-2147483649" "Error$"
set_test "0 -59 2147483648 5 9 1" "Error$"
set_test "2147483648161484 6 9 4" "Error$"
set_test "5555555555555555555555555555555 5 55 555 55555" "Error$"
set_test "1 68 4 8 2 13 4 9844 5168 894 2147483660" "Error$"
set_test "-214748364849453165448944516486484 4 5 684 2" "Error$"
display_error

value=5
for i in 1 2 3
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
        INS=$($PUSH $ARG)
        if [ ! "$INS" = "" ] ; then
            INS="$INS\n"
        fi
        NBR=$(printf "$INS" | wc -l)
        RES=$(printf "$INS" | $CHECKER $ARG)
        if [ "$RES" = "KO" ] ; then
            echo "\t$NBR -> ${RED}$RES${NC}\n\tyour program failed to sort $ARG"
        else
            printf "\t$NBR -> ${GREEN}$RES${NC}"
            grade_this $value $NBR
        fi
        NBR_TESTS=$(( NBR_TESTS - 1 ))
    done
    if [ $i = 1 ]
    then
        value=$((value * 20))
    else
        value=$((value * 5))
    fi
done