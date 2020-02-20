#!/bin/bash

function askForSure {
  while true; do
      read -p "Did you mean to release EmarsysSDK and EmarsysNotificationService '$1'? " yn
        case $yn in
            [Yy]* ) release $1 ; break;;
            [Nn]* ) exit;;
            * ) echo "Please answer yes or no.";;
        esac
  done
}

function release {
  VERSION_NUMBER="$1"
  if GIT_DIR=.git git rev-parse $VERSION_NUMBER >/dev/null 2>&1
  then
      printf "Version tag already exist, exiting...\n"
      exit
  fi

  printf "Releasing version $VERSION_NUMBER\n";

  printf "#define EMARSYS_SDK_VERSION @\"$VERSION_NUMBER\"" > Sources/EmarsysSDK/EmarsysSDKVersion.h

  TEMPLATE="`cat EmarsysSDK.podspec.template`"
  PODSPEC="${TEMPLATE/<VERSION_NUMBER>/$VERSION_NUMBER}"
  PODSPEC="${PODSPEC/<COMMIT_REF>/:tag => spec.version}"
  printf "$PODSPEC" > EmarsysSDK.podspec

  NSTEMPLATE="`cat EmarsysNotificationService.podspec.template`"
  NSPODSPEC="${NSTEMPLATE/<VERSION_NUMBER>/$VERSION_NUMBER}"
  NSPODSPEC="${NSPODSPEC/<COMMIT_REF>/:tag => spec.version}"
  printf "$NSPODSPEC" > EmarsysNotificationService.podspec

  git add Sources/EmarsysSDK/EmarsysSDKVersion.h
  git add EmarsysNotificationService.podspec
  git add EmarsysSDK.podspec
  git commit -m "chore(release): version set to $VERSION_NUMBER"
  git tag -a "$VERSION_NUMBER" -m "$VERSION_NUMBER"

  git push
  git push origin $VERSION_NUMBER

  pod spec lint
  pod trunk push EmarsysNotificationService.podspec
  pod trunk push EmarsysSDK.podspec

  printf "[$VERSION_NUMBER] released, go eat some cookies."
}

if [ -z $1 ]; then
  printf "USAGE: \r\n./release <version-number>\n";
  exit
else
  askForSure $1
fi
