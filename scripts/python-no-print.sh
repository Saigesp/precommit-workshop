#!/bin/sh

# Custom git pre-commit hook for finding and warning about
# Python print statements.
# Based on https://gist.github.com/stuntgoat/8800170

# Get the current git HEAD
head=`git rev-parse --verify HEAD`

# BSD regex for finding Python print statements
find_print='\+[[:space:]]*print[[:space:](]*'

# Save output to $out var
out=`git diff ${head} | grep -e ${find_print}`

# Count number of prints
count=`echo "${out}" | grep -e '\w' | wc -l`
if [ $count -gt 0 ];
   then
    echo "- Prints found:"
    echo "$out"
    echo "-" $count "print statement(s) founds!"
    echo
    exit 1
fi
