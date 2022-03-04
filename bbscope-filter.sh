#!/bin/bash

if [ $1 = '-h' ]
then 
	echo "Example: "
	echo "./bbscope-filter.sh file.txt"
	echo "Note: This script cleans up most of the cases but sometimes you may still have to do some manual work"

else
	mkdir results
	mkdir tld-enum

	# Grab ip addresses and ranges
	cat $1 | grep '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' | tee results/ips.txt &> /dev/null

	# Filter Wildcard Domains to be able to run Subdomain Enumeration on 'em

	cat $1 | grep  '^*\|\*\.' | sed 's/,/\n/g' | sed 's/https:\/\///;s/http:\/\///;s/\/.*//;s/^\*\.//;s/^[A-Za-z]\{1,60\}\-\*\.//;s/^[A-Za-z]\{1,60\}\*\.//;s/^\s//;s/^\*$//;s/^\*\.//;s/[A-Za-z]\{1,60\}\.\*\.//;s/^\*\-[A-Za-z]\{1,60\}\-\*\.//;s/^\*//;s/[a-zA-Z]\{1,60\}\-[a-zA-Z]\{1,60\}\*\.//;s/www\.paypal\-\*\.com//' | grep -v '*$' | sort -u | tee results/wildcard.txt &> /dev/null
	
	# Save those domains who need tld enum 
	cat $1 | sed 's/https:\/\///;s/http:\/\///;s/\*\.\*//' | grep '^\*' | grep '\.\*$' | sed 's/^\*\.//' | tee tld-enum/urls-wildcard.txt &> /dev/null
	cat $1 | sed 's/https:\/\///;s/http:\/\///;s/\*\.\*//' | grep -v '^\*\.' | grep '\.\*$' | tee tld-enum/urls-domains.txt &> /dev/null

	# domains.txt

	cat $1 | grep -v '^\*\.\|NO_IN_SCOPE_TABLE\|^com\.' | grep '\.' | sed 's/https:\/\///;s/http:\/\///;s/\/.*//' | sort -u | grep -v '\.\*$' | sed 's/,/\n/g' | grep -v '*\|\s' |  sed 's/.*)\.//' | grep -v '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\|\.apk$\|\.exe$' | tee results/domains.txt &> /dev/null

	# PRINT 
	echo -e '\n'
	echo "Done !"
	echo "1 - results/ips.txt Contains IP addresses from scopes"
	echo "2 - results/domains Contains only domains scope (not *.example.com)"
	echo "3 - results/wildcard.txt Contains domains that you should do should run sub-enum on 'em"
	echo "4 - tld-enum/ contains domains that you should manually bruteforce tld and you should append to the list after finish! "
	echo -e '\n'
fi
