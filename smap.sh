if [ $1 = '-h' ]
then 
	echo "Example: "
	echo "./smap.sh domains.txt"
  echo "Quickly Scan a bunch of targets using smap"

else


cat $1 | while read domain ;do smap $domain | awk '{print $1}' | grep "tcp\|udp" | sed 's/\/tcp//;s/\/udp//' | while read port ; do echo $domain:$port ;done ;done

fi
