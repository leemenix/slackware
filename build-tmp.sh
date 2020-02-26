#!/bin/bash
# Author: Milenko Letic
# Date: 23.Feb.2020
# TBD:
#    - automatic installation 
#    - dependency information
#    - general information before build


function debug(){
	echo "Defined values are: "
	echo "REPO_NAME=$REPO_NAME"
	echo "PKG_NAME=$PKG_NAME"
	if [[ -z "$3" ]]; then
		echo "SLACK_VER=$SLACK_VER"
	else
		echo "SLACK_VER=$3"
	fi
	echo "ENDPOINT=$ENDPOINT"
	echo "DEST_DIR=$DEST_DIR"

	echo "PACKAGE_URL=$PACKAGE_URL"
	#echo "PACKAGE_NAME=$PACKAGE_NAME"

	echo "FIRST_LINE=$FIRST_LINE"
	echo "LAST_LINE=$((LAST_LINE-1))"
}

function usage(){
	if [[ -z "$1" ]]; then
		echo "Please define repository name"
		echo "For usage check: "
		echo "	$0 --help"
		exit 0;
	fi

	if [[ -z "$2" ]]; then
		echo "Please define package name"
		echo "For usage check: "
		echo "	$0 --help"
		exit 0;
	fi
}

function check_input(){
#####
	if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
		echo "Usage: "
		echo "e.g. ./build office keepassx"
		echo "	- where office represent reporistory"
		echo "	- and keepassx represent package name"
        echo "	- third parameter represent Slackware version,"
        echo "	  and if not specified default value is 14.2"
		exit 0;
	fi
#####
	if [[ -z "$1" ]]; then
		usage $1 $2
	else
		export REPO_NAME="$1" 
	fi
#####
    if [[ -z "$2" ]]; then
    	usage $1 $2 
    else
    	export PKG_NAME="$2"
    fi
#####
	if [[ -z "$3" ]]; then
		export SLACK_VER="14.2"
	else 
		export SLACK_VER="$3"
	fi
}

function prepare_endpoint(){
	# https://slackbuilds.org/slackbuilds/14.2/office/keepassx.tar.gz
	export ENDPOINT="https://slackbuilds.org/slackbuilds/${SLACK_VER}/${REPO_NAME}/${PKG_NAME}.tar.gz"
	export DEST_DIR="$SLACK_VER/$REPO_NAME/$PKG_NAME"
	export PACKAGE_URL=`curl https://slackbuilds.org/repository/${SLACK_VER}/${REPO_NAME}/${PKG_NAME}/ \
			| grep "Source Downloads" | grep -Eo "(http|https)://[a-zA-Z0-9./?=_-]*"`
	# export PACKAGE_NAME=`curl https://slackbuilds.org/repository/${SLACK_VER}/${REPO_NAME}/${PKG_NAME}/ \
	# 		| grep "Source Downloads" | awk '{print $5}' | awk -F '>|<' '{print $2}'`
}

function prepare_destination(){
	mkdir -p $DEST_DIR
	wget $ENDPOINT -P $DEST_DIR/
	tar xvf $DEST_DIR/$PKG_NAME.tar.gz -C $DEST_DIR/

    local TEMP_FILE=`mktemp`
	curl https://slackbuilds.org/repository/${SLACK_VER}/${REPO_NAME}/${PKG_NAME}/ > $TEMP_FILE
	export FIRST_LINE=`awk '/Source Downloads/{ print NR; exit }' $TEMP_FILE`
	export LAST_LINE=`awk '/Download SlackBuild/{ print NR; exit }' $TEMP_FILE`
	
	for i in `sed ''"$FIRST_LINE"','"$((LAST_LINE-1))"'!d' $TEMP_FILE | awk -F'"' '{print $2}'`; do
		        wget $i -P $DEST_DIR/$PKG_NAME;
	done
	rm -f $TEMP_FILE

}

function build(){
	cd $DEST_DIR/$PKG_NAME/
	./$PKG_NAME.SlackBuild
}

############

function main(){

	check_input $1 $2 $3

	prepare_endpoint

	prepare_destination

	build

	debug

	exit 0;
}

############
main $1 $2 $3
