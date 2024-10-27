#!/bin/bash

LATEST_TAG=$(git describe --tags --abbrev=0)

if [ -z "$LATEST_TAG" ]; then
    NEW_TAG="v1.0.1"
else
    VERSION_BITS=(${LATEST_TAG//./ })
    V_MAJOR=${VERSION_BITS[0]//v/}
    V_MINOR=${VERSION_BITS[1]}
    V_PATCH=${VERSION_BITS[2]}

    V_PATCH=$((V_PATCH+1))

    NEW_TAG="v${V_MAJOR}.${V_MINOR}.${V_PATCH}"
fi

echo "NEW_TAG=$NEW_TAG" >> $GITHUB_ENV
