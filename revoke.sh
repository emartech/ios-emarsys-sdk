#!/bin/bash

function askForSure {
  while true; do
      read -p "Did you mean to revoke '$1' ? " yn
      case $yn in
          [Yy]* ) revoke $1 ; break;;
          [Nn]* ) exit;;
          * ) echo "Please answer yes or no.";;
      esac
  done
}

function revoke {
  VERSION_NUMBER=$1
  printf "revoking $VERSION_NUMBER"

  if GIT_DIR=.git git rev-parse $VERSION_NUMBER >/dev/null 2>&1
  then
      printf "Reverting commit related to $VERSION_NUMBER...\n"
      git revert $VERSION_NUMBER
      git push
      printf "Commit reverted.\n"

      printf "Version tag found, removing tag $VERSION_NUMBER...\n"
      git tag -d $VERSION_NUMBER
      git push origin :refs/tags/$VERSION_NUMBER
      printf "$VERSION_NUMBER tag removed.\n"

      printf "Removing $VERSION_NUMBER from Cocoapod...\n"
      pod trunk delete MobileEngageSDK $VERSION_NUMBER
      printf "Removed $VERSION_NUMBER from Cocoapod.\n"
      exit
  else
      printf "Can't find $VERSION_NUMBER tag, exiting...\n"
  fi
}

VERSION_NUMBER="$1"
if [ -z $VERSION_NUMBER ]; then
  printf "USAGE: \r\n./revoke <version-number>\n\n";
  LAST_TAG=`git describe --abbrev=0`

  askForSure $LAST_TAG
else
  askForSure $1
fi
