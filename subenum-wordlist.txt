#!/bin/bash

if [ $1 = '-h' ]
then 
    echo "Example: "
    echo "./wordlist-subenum.sh dns-wordlist.txt domains-list.txt output.txt"
    echo "[-] This is an another way to do subdomain enumeration by generating subdomains from a DNS Wordlist 
    and then resolving, It takes much less than all DNS-brute-forcing tools."
    echo "[*] The output can be given to a tool like shuffledns."
else

cat $2 | while read domain do ; do cat $1 | while read dns do ; do echo "$dns.$domain" | tee -a $3 ;done ;done

fi
