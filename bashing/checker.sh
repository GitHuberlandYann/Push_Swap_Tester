#!/bin/sh

PURPLE='\033[0;35m'
RED='\033[0;31m'
GREEN='\033[0;32m'
BRED='\033[1;31m'
BGREEN='\033[1;32m'
NC='\033[0m' # No Color

#   ---- functions ----   #

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
        ERRORS="$ERRORS\tTest $COUNT : $1 returned '$RES' instead of '$EXPECTED_RES' when called with ARG='$ARG' and '$INS' as instructions.\n"
        GRADE="KO"
    fi
    COUNT=$(( COUNT + 1 ))
}

set_test()
{
    ARG=$1
    INS=$2
    RES=$(printf "$INS" | ./$3 $ARG 2>&1 | cat -e)
    EXPECTED_RES=$4
    display_result $3
}

display_error()
{
    printf "${RED}$ERRORS${NC}"
    if [ ! "$ERRORS" = "\n" ] ; then
        ERRORS="\n"
    fi
}

#   --- main ---   #

GRADE="OK"
ERRORS="\n"

printf_test "no argument"
set_test "" "" $1 ""
set_test "" "sa" $1 ""
display_error

printf_test "non numerical arguments"
set_test "0 1 2 d 3" "" $1 "Error$"
set_test "text" "" $1 "Error$"
set_test "0 1 2 3.5 4" "" $1 "Error$"
set_test "1 * 0" "sa" $1 "Error$"
set_test "! # $" "ra" $1 "Error$"
set_test "0 ++1 2 3" "rr" $1 "Error$"
set_test "0 1- 2 3" "rr" $1 "Error$"
set_test "0 + 2 3" "rr" $1 "Error$"
set_test "one two three" "" $1 "Error$"
set_test "3 2 one 0" "" $1 "Error$"
display_error

printf_test "2 identical arguments"
set_test "0 0" "" $1 "Error$"
set_test "5 3 1 2 4 2" "" $1 "Error$"
set_test "0 1 2 3 4 5 6 2 7 8 9 10 11" "" $1 "Error$"
set_test "-8 -129 14 2147596 -129 -46" "" $1 "Error$"
set_test "19 50 36 48 76 36 82 36" "" $1 "Error$"
display_error

printf_test "invalid numbers"
set_test "2147483648" "" $1 "Error$"
set_test "-2147483649" "" $1 "Error$"
set_test "0 -59 2147483648 5 9 1" "" $1 "Error$"
set_test "2147483648161484 6 9 4" "" $1 "Error$"
set_test "5555555555555555555555555555555 5 55 555 55555" "" $1 "Error$"
set_test "1 68 4 8 2 13 4 9844 5168 894 2147483660" "" $1 "Error$"
set_test "-214748364849453165448944516486484 4 5 684 2" "" $1 "Error$"
display_error

printf_test "invalid instructions"
set_test "0 2 1" "sasa
" $1 "Error$"
set_test "0 2 1" "sa
sc
" $1 "Error$"
set_test "0 2 1" "pp" $1 "Error$"
set_test "0 2 1" "salsa" $1 "Error$"
set_test "0 2 1" "sa
sa
ra
rr
sort
" $1 "Error$"
set_test "0 2 1" "sa 
" $1 "Error$"
set_test "0 2 1" " sa
" $1 "Error$"
set_test "0 2 1" "sa
sa 
sa
" $1 "Error$"
set_test "0 2 1" "sa
 sa
sa
" $1 "Error$"
set_test "0 2 1" "sa

sa
" $1 "Error$"
set_test "0 2 1" "0 2 1" $1 "Error$"
set_test "0 2 1" "pa" $1 "Error$"
set_test "0 2 1" "ra" $1 "Error$"
set_test "0 2 1" "rra" $1 "Error$"
set_test "0 2 1" "pb" $1 "Error$"
set_test "0 2 1" "ss" $1 "Error$"
set_test "0 2 1" "sb" $1 "Error$"
set_test "0 2 1" "rb" $1 "Error$"
set_test "0 2 1" "rrb" $1 "Error$"
set_test "0 2 1" "rrr" $1 "Error$"
set_test "0 2 1" "s" $1 "Error$"
display_error

printf_test "wrong instructions"
set_test "0 9 1 8 2 7 3 6 4 5" "sa
pb
rrr
" $1 "KO$"
set_test "0 2 +1" "sa
" $1 "KO$"
set_test "0 2 1" "rra
sb
sa
rb
ra
" $1 "KO$"
set_test "0 2 1" "rr
rr
rr
rr
ra
ra
ra
rb
rb
rra
rra
rra
sa
sa
sa
" $1 "KO$"
set_test "0 2 1" "sa
pb
" $1 "KO$"
set_test "3 2 1 0" "sa
rra
pb
" $1 "KO$"
display_error

printf_test "good instructions"
set_test "0 1 2" "" $1 "OK$"
set_test "0 +5 984 2165414 2147483647" "" $1 "OK$"
set_test "-2147483648 -2147483647 -1 0 1 2147483646 2147483647" "" $1 "OK$"
set_test "0 9 1 8 2" "pb
ra
pb
ra
sa
ra
pa
pa
" $1 "OK$"
set_test "0 2 1" "sa
ra
" $1 "OK$"
set_test "0 2 1" "pb
sa
sb
pb
sa
pb
rrr
rrr
rrb
pa
pa
pa
" $1 "OK$"
set_test "0 2 1" "sa
sa
pb
pb
rb
rrb
sb
sb
rr
rrr
ss
ss
pa
ss
ss
pa
ra
rra
pb
sa
pa
" $1 "OK$"
set_test "3 2 1 0" "rra
pb
sa
rra
pa
" $1 "OK$"
display_error

if [ "$GRADE" = "OK" ] ; then
    printf "Your checker passed all the tests, should be good !\nDon't forget to check for leaks as this tester doesn't ${GREEN}:)${NC}\n"
fi