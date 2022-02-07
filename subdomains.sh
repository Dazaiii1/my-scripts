#!/bin/bash
if [ $1 = '-h' ]
then 
	echo "Example: "
	echo "./subdomains.sh file.txt"

else
  mkdir results
  cat $1 | while read domain do ; do amass enum -passive -norecursive -noalts -d $domain -o $domain.amass ;done
  cat $1 | while read domain do ; do subfinder -d $domain -silent -t 100 | tee $domain.subfinder ;done
  cat $1 | while read domain do ; do cat $domain.* | tee results/$domain.txt ;done
  rm *.subfinder ; rm *.amass
fi
