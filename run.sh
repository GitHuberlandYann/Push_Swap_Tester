#!/bin/sh

DIR=./bashing
BASIC=./bashing/custom.sh
GRADE=./bashing/grade.sh
CHECKER=./bashing/checker.sh

check_file()
{
	if [ ! -f $1 ] ; then
		echo "Can't find the file $1, make sure it exists and try again."
		exit
	elif [ ! -x $1 ] ; then
		echo "The file $1 is not an executable.\nUse the command -> chmod +x $1 <- and then try again."
		exit
	fi
}

if [ ! -d $DIR ] ; then
	echo "You deleted or renamed the directory $DIR"
	return
fi

check_file $BASIC
check_file $GRADE
check_file $CHECKER

if [ $# -eq 0 ] ; then
	$BASIC
elif [ $# -eq 1 ] ; then
	if [ -n "$1" ] && [ "$1" -eq "$1" ] 2>/dev/null ; then
		if [ $1 -ge 1 ] ; then
			$BASIC $1
		else
			echo "$1 is not greater than 0."
		fi
	elif [ "$1" = "parrot" ] ; then
		curl parrot.live
	elif [ "$1" = "-checker" ] || [ "$1" = "-c" ] ; then
		echo "Wrong format.\n'./run.sh $1' needs 1 more argument."
	elif [ "$1" = "-grade" ] || [ "$1" = "-g" ] ; then
		$GRADE
	else
		echo "$1 is not a number or an executable file."
	fi
elif [ $# -eq 2 ] ; then
	if [ -n "$1" ] && [ "$1" -eq "$1" ] 2>/dev/null ; then
		$BASIC $1 $2
	elif [ "$1" = "-checker" ] || [ "$1" = "-c" ] ; then
		check_file $2
		$CHECKER $2
	elif [ "$1" = "-grade" ] || [ "$1" = "-g" ] ; then
		$GRADE $2
	else
		echo "$1 is not a valid argument."
	fi
else
	echo "Wrong number of arguments."
fi
