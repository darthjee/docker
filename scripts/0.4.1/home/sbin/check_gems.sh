#!/bin/bash

function missing_gems() {
  bundle check 2>&1 | grep " (" | sed -e "s/ *\* *\(.*\) (\(.*\))/\1:\2/g"
}

function check_bundle() {
  LIST=$(missing_gems)

  if [[ $LIST ]]; then
    exit 1
  else
    exit 0
  fi
}

function upgrade_all() {
  LIST=$(list_upgrades)

  for MATCH in $LIST; do
    NAME=${MATCH%%:*}
    VERSION=${MATCH##*:}
    NEW_VERSION=$(latest_version $NAME)

    if [[ $NEW_VERSION ]]; then
      sed -e "s/gem *['\"]$NAME['\"] *$/gem '$NAME', '$NEW_VERSION'/g" -i Gemfile
      sed -e "s/gem *['\"]$NAME['\"],\( *\)['\"].*['\"]$/gem '$NAME',\\1'$NEW_VERSION'/g" -i Gemfile

      if [ -r *.gemspec ]; then
        sed -e "s/_dependency *['\"]$NAME['\"] *$/_dependency '$NAME', '$NEW_VERSION'/g" -i *.gemspec
        sed -e "s/_dependency *['\"]$NAME['\"],\( *\)['\"].*['\"]$/_dependency '$NAME',\\1'$NEW_VERSION'/g" -i *.gemspec
      fi
    fi
  done

  bundle install
}

function latest_version() {
  NAME=$1
  LINE=$(gem list | grep "^$NAME ")

  if [[ $LINE ]]; then
    echo $LINE | sed -e "s/.* (//g" | sed -e "s/) *//g" | sed -e "s/,//g" | sed -e "s/ /\\n/g" | head -n 1
  fi
}

function list_upgrades() {
  LIST=$(missing_gems)

  for MATCH in $LIST; do
    NAME=${MATCH%%:*}
    VERSION=${MATCH##*:}
    NEW_VERSION=$(latest_version $NAME)

    if [[ $NEW_VERSION ]]; then
      echo "$NAME:$VERSION:$NEW_VERSION"
    fi
  done
}

ACTION=$1

case $ACTION in
  "check")
    check_bundle
    ;;
  "list_missing")
    missing_gems
    ;;
  "upgrade")
    upgrade_all
    ;;
  "list_upgrades")
    list_upgrades
    ;;
  *)
    echo "Usage:"
    echo "$0 check # checks if gems have been installed"
    echo "$0 list_missing # shows list of missing / wrng version gems"
    echo "$0 upgrade # upgrade gems from gemfile when they are outdated # checks if gems have been installed"
    echo "$0 list_upgrades # list all gems to be upgraded by the upgrade"
    ;;
esac
