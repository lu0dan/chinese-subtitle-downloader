#!/bin/bash
# -----------------------------------------
# Common Library for Subtitle downloader
# by luodan@gmail.com
# v0.9 2015.08.12
# -----------------------------------------

is_command_available() {
	type "$@">/dev/null 2>&1 && return 0
	return 1
}

log(){
	local PREFIX=
	[ "$CSD_LOG_PREFIX" != "" ] && PREFIX="[$CSD_LOG_PREFIX]"
	if [ "x$CSD_LOG_LEVEL" == "x" -o "$CSD_LOG_LEVEL" == "0" -o "x$CSD_LOG_FILE" == "x" ]; then
		echo $PREFIX "$@"
	else
		echo [`date "+%Y-%m-%d %H:%M:%S"`]$PREFIX "$@" >> $CSD_LOG_FILE
	fi
}

get_file_mainname(){
	FILE_MAINNAME=`basename "$1"`
	FILE_MAINNAME=${FILE_MAINNAME%.*}
}

get_file_extension(){
	FILE_EXTENSION=${1##*.}
}

is_video(){
	[ "x$VIDEO_FILE_EXTENSIONS" == "x" ] && VIDEO_FILE_EXTENSIONS="avi|mkv|wmv|m4v|mp4"
	return `echo $@|awk 'BEGIN{s=1;}{s=match($0, /\.('$VIDEO_FILE_EXTENSIONS')$/)?0:1;}END{print s;}'`
}

CDIR=`dirname "$0"`
CNAME=`basename "$0"`
[ "$DEBUG" == "*" -o "$DEBUG" != "${DEBUG//$CNAME/}" ] && set -x

if [ "x$CSD_DIRECTORY" == "x" ]; then
	export CSD_DIRECTORY=`cd "$CDIR"; pwd`
	[ "${CSD_DIRECTORY##*/}" == "scripts" ] && export CSD_DIRECTORY=${CSD_DIRECTORY%/scripts}
fi

[ ! -f "$CSD_DIRECTORY/subtitle.conf" ] && echo Subtitle config file not found, abort && exit 1
. "$CSD_DIRECTORY/subtitle.conf"

if [ "x$CSD_LOG_FILE" == "x" ]; then
	export CSD_LOG_FILE="$CSD_DIRECTORY/$LOG_FILE"
	export CSD_LOG_LEVEL=0
	export CSD_SCRIPTS_DIRECTORY="$CSD_DIRECTORY/$SCRIPTS_DIRECTORY_NAME"
	export CSD_TEMP_DIRECTORY="$CSD_DIRECTORY/$TEMP_DIRECTORY_NAME"
	export PS_COMMAND="ps" && [ `ps|wc -l` -lt 10 ] && export PS_COMMAND="ps aux"
fi

[ ! -d "$CSD_TEMP_DIRECTORY" ] && mkdir -p "$CSD_TEMP_DIRECTORY"
[ ! -w "$CSD_TEMP_DIRECTORY" ] && echo "ERROR: Temporary directory not accessable." && exit 1

LOG_FILE_DIRECTORY=`dirname "$CSD_LOG_FILE"`
[ ! -d "$LOG_FILE_DIRECTORY" ] && mkdir -p "$LOG_FILE_DIRECTORY"
[ ! -w "$LOG_FILE_DIRECTORY" ] && export $CSD_LOG_FILE=
unset LOG_FILE_DIRECTORY

MODEL_NAME=`basename "$0"`
MODEL_NAME=${MODEL_NAME%.sh}
[ "$MODEL_NAME" == "subtitle" ] && export CSD_LOG_PREFIX= || export CSD_LOG_PREFIX="$MODEL_NAME"

