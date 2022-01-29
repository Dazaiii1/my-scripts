#!/usr/bin/bash

function UPDATE {

    sudo xbps-install -Suv
}

function MAINTAIN {

    sudo xbps-remove -Oo
}

function INSTALL {

    local PKG
    local ARG_I
    
    # selecting of packages to install
    # flags multi to be able to pick multiple packages
    # exact to match exact match
    # no sort self explanatory
    # cycle to enable cycle scroll
    # reverse to set orientation to reverse
    # margin for margins
    # inline info to display info inline
    # preview to show the package description 
    # header and prompt to give info for people to know how to do stuff
    
    PKG="$( xbps-query -Rs "" | sort -u | grep -v "*" | fzf -i \
                    -m -e --no-sort --border=rounded -1 -q "$ARG_I" \
                    --cycle --reverse --margin="4%,1%,1%,2%" \
                    --inline-info \
                    --preview 'xbps-query -R {2}' \
                    --preview-window=right:55%:wrap \
                    --header="TAB TO (UN)SELECT. ENTER TO INSTALL. ESC TO QUIT." \
                    --prompt="FILTER : " | awk '{print $2}' )"

            PKG="$( echo "$PKG" | paste -sd " " )"
            if [[ -n "$PKG" ]]
            then 
            clear
            sudo xbps-install -S $PKG
            fi
}

function PURGE {

    local PKG
    local ARG_I

    PKG="$( xbps-query -l | sort -u | fzf -i \
                    -m -e --no-sort --border=rounded -1 -q "$ARG_I" \
                    --cycle --reverse --margin="4%,1%,1%,2%" \
                    --inline-info \
                    --preview 'xbps-query -S {2}' \
                    --preview-window=right:55%:wrap \
                    --header="TAB TO (UN)SELECT. ENTER TO PURGE. ESC TO QUIT." \
                    --prompt="FILTER : " | awk '{print $2}' )"
            
            PKG="$( echo "$PKG" | paste -sd " " )"
            if [[ -n "$PKG" ]]
            then 
            clear
            sudo xbps-remove -R $PKG
            fi
}

function HOLD {

    local PKG
    local ARG_I 
    
    PKG="$( xbps-query -l | sort -u | fzf -i \
                    -m -e --no-sort --border=rounded -1 -q "$ARG_I" \
                    --cycle --reverse --margin="4%,1%,1%,2%" \
                    --inline-info \
                    --preview 'xbps-query -S {2}' \
                    --preview-window=right:55%:wrap \
                    --header="TAB TO (UN)SELECT. ENTER TO PLACE ON HOLD. ESC TO QUIT." \
                    --prompt="FILTER : " | awk '{print $2}' )"
            
            PKG="$( echo "$PKG" | paste -sd " " )"
            if [[ -n "$PKG" ]]
            then 
            clear
            sudo xbps-pkgdb -m hold $PKG
            fi
}

function UNHOLD {
    
    local PKG
    local ARG_I

    PKG="$( xbps-query -p hold -s "" | sort -u | fzf -i \
                    -m -e --no-sort --border=rounded -1 -q "$ARG_I" \
                    --cycle --reverse --margin="4%,1%,1%,2%" \
                    --inline-info \
                    --header="TAB TO (UN)SELECT. ENTER TO UNHOLD. ESC TO QUIT." \
                    --prompt="FILTER : " | awk '{print $1}' )"
            
            PKG="$( echo "$PKG" | paste -sd " "| tr -d ":" )"
            if [[ -n "$PKG" ]]
            then 
            clear
            sudo xbps-pkgdb -m unhold $PKG
            fi
}

function UI {
while true
do
    clear
    echo
        echo -e "                 \e[7m XbpsUI - PACKAGE MANAGER \e[0m"
        echo
        echo -e " ┌───────────────────────────────────────────────────────┐"
        echo -e " │    0   \e[1mQ\e[0muit                                           │"
        echo -e " │    1   \e[1mU\e[0mpdate System           2   \e[1mM\e[0maintain System    │"
        echo -e " │    3   \e[1mI\e[0mnstall Packages        4   \e[1mP\e[0murge Packages     │"
        echo -e " │    5   \e[1mH\e[0mold Packages           6   \e[1mU\e[0mnHold Packages    │"  
        echo    " └───────────────────────────────────────────────────────┘"
        echo

        echo -n "  Enter Number OR Marked Letter(S): "
        read -r CHOICE
        CHOICE="$(echo "$CHOICE" | tr '[:upper:]' '[:lower:]' )"
        echo
   
        case "$CHOICE" in
            1|u|update )
                UPDATE
                echo
                echo -e " \e[41m SYSTEM UPDATE FINISHED. To return to XbpsUI Press ENTER \e[0m"
                read
                ;;
            2|m|maintain )
                MAINTAIN
                echo
                echo -e " \e[41m SYSTEM MAINTENANCE FINISHED. To return to XbpsUI Press ENTER \e[0m"
                read
                ;;
            3|i|install )
                INSTALL
                echo
                echo -e " \e[41m PACKAGE(S) INSTALLED. To return to XbpsUI Press ENTER \e[0m"
                read
                ;;
            4|p|purge )
                PURGE
                echo
                echo -e " \e[41m PACKAGE(S) PURGED. To return to XbpsUI Press ENTER \e[0m"
                read
                ;;
            5|h|hold )
                HOLD
                echo
                echo -e " \e[41m PACKAGE(S) HELD. To return to XbpsUI Press ENTER \e[0m"
                read
                ;;
            6|u|unhold )
                UNHOLD
                echo
                echo -e " \e[41m PACKAGE(S) UNHELD. To return to XbpsUI Press ENTER \e[0m"
                read
                ;;
            0|q|quit )
                clear && exit
                ;;

            * )
                echo -e "  \e[41m WRONG OPTION \e[0m"
                echo -e "  \e[41m PLEASE TRY AGAIN... \e[0m"
                sleep 0.5
                ;;

      esac   
      done
}
    
UI
