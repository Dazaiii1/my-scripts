#!/bin/bash

if [ $1 = '-h' ]
then 
	echo "Example: "
	echo "./bbscope-filter.sh file.txt"
	echo "Note: This script is not perfect , It cleans up a lot of cases but you still have to do some manual work"

else
	mkdir results
	mkdir tld-enum

		# Grab ip addresses and ranges
	cat $1 | grep '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' | tee results/ips.txt &> /dev/null

	# Filter Wildcard Domains to be able to run Subdomain Enumeration on 'em

	cat $1 | grep '\*' | sed 's/http:\/\///;s/https:\/\///;s/^\*\.//;s/^[\*]\{1,2\}[a-z]\{1,100\}\*//;s/^[a-z]\{1,50\}\*//;s/[A-Za-z]\{1,50\}\.\*\.//;s/^\.//' | grep -v "github\.com" | grep '[A-Za-z]' | sed 's/\/\*//' | cut -d "/" -f1 | grep "\." | grep -v "\.\*" | tee results/wildcard.txt &> /dev/null

	cat $1 | grep '\*' | sed 's/http:\/\///;s/https:\/\///;s/^\*\.//;s/^[\*]\{1,2\}[a-z]\{1,100\}\*//;s/^[a-z]\{1,50\}\*//;s/[A-Za-z]\{1,50\}\.\*\.//;s/^\.//' | grep -v "github\.com" | grep '[A-Za-z]' | sed 's/\/\*//' | cut -d "/" -f1 | grep "\." | grep "\.\*" | tee tld-enum/urls.txt &> /dev/null


	# domains.txt

	cat $1 | grep -v '\*' | grep -v "^com\." | grep -v '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' | cut -d "/" -f3 | grep -v 'github\.com' | grep '[A-Za-z]' | grep -v "NO_IN_SCOPE_TABLE" | grep -v '(\|)\|Desktop Application' | grep '\.' | tee results/domains.txt &> /dev/null

	# PRINT 
	echo -e '\n'
	echo "Done !"
	echo "1 - results/ips.txt Contains IP addresses from scopes"
	echo "2 - results/domains Contains only domains scope (not *.example.com)"
	echo "3 - results/wildcard.txt Contains domains that you should do should run sub-enum on 'em"
	echo "4 - tld-enum/ contains domains that you should manually bruteforce tld and you should append to the list after finish! "
	echo -e '\n'
fi
