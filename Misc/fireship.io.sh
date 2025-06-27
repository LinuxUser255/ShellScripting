#!/usr/bin/env bash

# must be root to run this script
[ $EUID -ne 0 ] && echo "Don't run this script, it's for refrence only, But it can be run as root" ||

# using brace expansion to create multiple files
touch file{1..15}.txt

# make multiple combos of 'folders' by sorrounding the path with segments and braces
mkdir -p ./home/{a,b}/{x,y,z} #

# to return to the original directory
cd -



