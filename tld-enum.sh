if [ $1 = '-h' ]
then 
	echo "Example: "
	echo "./tld-enum.sh urls.txt tlds.txt output.txt"
  echo "Note 1 : urls.txt contains lines like "
  echo "company.*"
  echo "company2.*"
  echo "Note 2 : tlds.txt" 
  echo "download it from https://gist.githubusercontent.com/wridgers/1968862/raw/ca71d75354fc2fc833a62a00f15f5dc0180b2ee9/tlds.txt"
  echo "and then remove points from the wordlist : sed -i 's/\.//' tlds.txt "

else

sed 's/\.\*//' $1  |  while read url do; do ffuf -u https://$url.FUZZ/ -w $2 -s | while read tld do; do echo $url.$tld | tee -a $3 ;done ;done

fi
