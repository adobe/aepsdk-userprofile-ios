#!/usr/bin/env bash

set -e

if which jq >/dev/null; then
    echo "jq is installed"
else
    echo "error: jq not installed.(brew install jq)"
fi

NC='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'

#  ---- enable the following code after the new pod has been released. ----
# LATEST_PUBLIC_VERSION=$(pod spec cat AEPRulesEngine | jq '.version' | tr -d '"')
# echo "Latest public version is: ${BLUE}$LATEST_PUBLIC_VERSION${NC}"
# if [[ "$1" == "$LATEST_PUBLIC_VERSION" ]]; then
#     echo "${RED}[Error]${NC} $LATEST_PUBLIC_VERSION has been released!"
#     exit -1
# fi

echo "Start to check the version in podspec file >"
echo "Expected to release:"
echo "  - AEPProfile: ${BLUE}$1${NC}"
echo "  - Dependencies:"
echo "    - AEPCore: ${BLUE}$2${NC}"
echo "    - AEPService: ${BLUE}$3${NC}"

PODSPEC_VERSION=$(pod ipc spec AEPUserProfile.podspec | jq '.version' | tr -d '"')
CORE_VERSION=$(pod ipc spec AEPUserProfile.podspec | jq '.dependencies.AEPCore[0]' | tr -d '"')
SERVICE_VERSION=$(pod ipc spec AEPUserProfile.podspec | jq '.dependencies.AEPServices[0]' | tr -d '"')
echo "Local podspec:"
echo " - version: ${BLUE}${PODSPEC_VERSION}${NC}"
echo " - depdendencies:"
echo "   - AEPCore: ${BLUE}${CORE_VERSION}${NC}"
echo "   - AEPService: ${BLUE}${SERVICE_VERSION}${NC}"

SOUCE_CODE_VERSION=$(cat ./AEPUserProfile/Sources/UserProfileConstants.swift | egrep '\s*EXTENSION_VERSION\s*=\s*\"(.*)\"' | ruby -e "puts gets.scan(/\"(.*)\"/)[0] " | tr -d '"')
echo "Souce code version - ${BLUE}${SOUCE_CODE_VERSION}${NC}"

if [[ "$1" == "$PODSPEC_VERSION" ]] && [[ "$1" == "$SOUCE_CODE_VERSION" ]] && [[ "$2" == "$CORE_VERSION" ]] && [[ "$3" == "$SERVICE_VERSION" ]]; then
    echo "${GREEN}Pass!"
    exit 0
else
    echo "${RED}[Error]${NC} Version do not match!"
    exit -1
fi
