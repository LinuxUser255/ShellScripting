#!/usr/bin/env bash

# make multiple combos of 'folders' by sorrounding the path with segments and braces
mkdir -p ./home/{a,b}/{x,y,z} #

# to return to the original directory
cd -

# using brace expansion to create multiple files
touch file{1..15}.txt
