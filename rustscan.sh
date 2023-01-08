cat $1 | while read domain ;do rustscan -a $domain --ulimit 5000 | grep Open | awk '{print $2}' | sed "s/^.*://;s/^/$domain:/" ;done
