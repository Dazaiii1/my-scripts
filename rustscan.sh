#2022 Way

cat $1 | while read domain ;do rustscan -a $domain --ulimit 5000 | grep Open | awk '{print $2}' | sed "s/^.*://;s/^/$domain:/" ;done

#2023 way ( Json Format )

echo ncs.nintendo.com | while read domain; do rustscan -a $domain --ulimit 5000 | grep Open | while read line; do ip=$(echo "$line" | cut -d' ' -f2); port=${line##*:}; echo "{\"ip\": \"$ip\", \"domain\": \"$domain:$port\"}"; done; done

# 2023 Q4 way

cat $1 | while read domain ;do rustscan -a $domain --ulimit 10000 --scripts None -b 5000 | grep Open | awk '{print $2}' | sed "s/^.*://;s/^/$domain:/" ;done

# 2024 way
cat $1 | while read domain ;do rustscan -a $domain --ulimit 10000 --scripts None -b 200 -t 1500 | grep Open | awk '{print $2}' | sed "s/^.*://;s/^/$domain:/" ;done
