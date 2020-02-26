#!/bin/bash

if [[ $1 == "--help" ]] || [[ $1 == "-h" ]]; then
	echo "Usage: "
	echo "e.g. ./build.sh keepassx"
        exit 0;
fi

if [[ -z "$1" ]]; then
	echo "Please define package name"
	exit 0;
else
	export PKG_NAME="$1"
fi

if [[ -z "$3" ]]; then
	export SLACK_VER="14.2"
fi

export DEST_DIR="$SLACK_VER/$PKG_NAME"

mkdir -p $DEST_DIR
cd $DEST_DIR
lftp -c "open http://www.slackware.com/~alien/slackbuilds/${PKG_NAME}/; mirror build"


cd ./build
lftp -c "open http://www.slackware.com/~alien/slackbuilds/${PKG_NAME}/pkg64/${SLACK_VER}/; mirror ."

chmod +x ./$PKG_NAME.SlackBuild
./$PKG_NAME.SlackBuild
