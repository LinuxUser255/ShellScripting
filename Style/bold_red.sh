#!/usr/bin/env bash

bold_red() {
    printf "\e[1;31m%s\e[0m\n" "$*"
}

# $#   length — gets the length of a string or array
[ $# -ne 2 ] && bold_red "$*" || echo "Usage: bold_red <text>"


#if: [ $# -ne 2 ]; then
#                        "$*"      expands to "$1 $2 ..." — all args in one string
#    bold_red "$*"
#else
#    echo "Usage: bold_red <text>"
#fi

# use conditional expression
# ternirary operator breakdown into three parts
# condition? true_value : false_value
# eliminate if
# place the condition in brackets  [ thing condition ]
# the if is replaced by &&
# then the thing to do is placed after the &&
# the else is replaced by : ||
# then the rest is placed after the ||
# [ thingtotestfor the-condition ] && thing-you-want "$*" || echo "Usage: bold_red <text>"




