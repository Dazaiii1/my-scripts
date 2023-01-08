#!/bin/bash

if [ $1 = '-h' ]
then 
	echo "Example: "
	echo "./grep-format.sh file.txt"
	echo "Helps generating patterns from a file in grep format"

else


cat $1 | sed 's/$/\\|/' | tr '\n' ',' | tr -d ',' | sed 's/\\|$//;s/^/"/;s/$/"/;s/$/\n/;s/^/grep /'

fi
