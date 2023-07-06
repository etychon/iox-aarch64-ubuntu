#!/bin/sh
set -ex

# Read the package version number
VERSION=$(cat VERSION)

# Change the package.yaml to reflect the version
sed -i "/^\([[:space:]]*version: \).*/s//\1\"$VERSION\"/" package.yaml

# Build a version of the Docker image
docker build -t ubuntu-iox-aarch64:${VERSION} .  

# Package with IOx
ioxclient docker package ubuntu-iox-aarch64:${VERSION} . --auto --use-targz -n ubuntu-IOx-aarch64-${VERSION}
