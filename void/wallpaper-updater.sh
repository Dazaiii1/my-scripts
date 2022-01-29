echo "Usage : ./exec <path/to/new/wallpaper>"

xfconf-query --channel xfce4-desktop --list | grep last-image | while read path do; do xfconf-query --channel xfce4-desktop --property $path --set $1  ;done
