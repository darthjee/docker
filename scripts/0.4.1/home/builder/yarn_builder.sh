#!/bin/bash

ARGS=$(echo $* | xargs)

SED='/[dD]ependencies": {/,/}/ {s/    "\([^"]*\)": *"\(.*\)",\?/\1@\2/gp}'

echo $SED > /tmp/package_sed.sed

#sed -f /tmp/package_sed.sed package.json -n > out.txt
npm install -g $(sed -f /tmp/package_sed.sed package.json -n)
