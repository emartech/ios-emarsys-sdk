#!/bin/bash

VERSION_NUMBER=$1
printf "Deploying version $VERSION_NUMBER to private cocoapods...\n";

TEMPLATE="`cat EmarsysSDK.podspec.template`"
PODSPEC="${TEMPLATE/<VERSION_NUMBER>/$VERSION_NUMBER}"
COMMIT_HASH=$(git rev-parse HEAD)
PODSPEC="${PODSPEC/<COMMIT_REF>/:commit => '$COMMIT_HASH'}"
printf "$PODSPEC" > EmarsysSDK.podspec

pod repo push emapod EmarsysSDK.podspec --allow-warnings

printf "[$VERSION_NUMBER] deployed to private cocoapod."
