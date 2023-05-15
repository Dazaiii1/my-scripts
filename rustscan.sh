#2022 Way

cat $1 | while read domain ;do rustscan -a $domain --ulimit 5000 | grep Open | awk '{print $2}' | sed "s/^.*://;s/^/$domain:/" ;done

#2023 way ( Json Format )

echo ncs.nintendo.com | while read domain; do rustscan -a $domain --ulimit 5000 | grep Open | while read line; do ip=$(echo "$line" | cut -d' ' -f2); port=${line##*:}; echo "{\"ip\": \"$ip\", \"domain\": \"$domain:$port\"}"; done; done
