#!/usr/bin/env bash
example_text="${@-Example preview text (no file provided}"
# ======= initial RGB values =======
rfg=0; gfg=127; bfg=97
rbg=255; gbg=255; bbg=255

draw_preview() {
    printf "\033[2J\033[H"   # clear screen

    FG="\033[38;2;${rfg};${gfg};${bfg}m"
    BG="\033[48;2;${rbg};${gbg};${bbg}m"
    RESET="\033[0m"

    echo "Foreground: R=$rfg G=$gfg B=$bfg   (r/g/b to +5, R/G/B to -5)"
    echo "Background: R=$rbg G=$gbg B=$bbg   (e/f/v to +5, E/F/V to -5)"
    echo "Press q to quit."
    echo ""
    printf "| ${FG}${BG}%s${RESET} |\n" "$example_text"
}

adjust() {
    var=$1
    delta=$2
    val=$(eval echo \$$var)
    val=$((val + delta))
    [ $val -lt 0 ] && val=0
    [ $val -gt 255 ] && val=255
    eval $var=$val
}

draw_preview

while true; do
    IFS= read -rsn1 key

    case "$key" in
        q)
            echo ""
            echo "Your ANSI command:"
            echo ""
            echo "echo -e \"\\033[38;2;${rfg};${gfg};${bfg}m\\033[48;2;${rbg};${gbg};${bbg}m${example_text}\\033[0m\""
            echo ""
            exit 0
            ;;

        r) adjust rfg +1 ;;
        g) adjust gfg +1 ;;
        b) adjust bfg +1 ;;
        R) adjust rfg -1 ;;
        G) adjust gfg -1 ;;
        B) adjust bfg -1 ;;

        e) adjust rbg +1 ;;
        f) adjust gbg +1 ;;
        v) adjust bbg +1 ;;
        E) adjust rbg -1 ;;
        F) adjust gbg -1 ;;
        V) adjust bbg -1 ;;
    esac

    draw_preview
done
