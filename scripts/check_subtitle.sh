#!/bin/bash
# -------------------------------------------
# Check if subtitles already exist 
# by luodan@gmail.com
# v0.9 2015.08.12
# -------------------------------------------

CDIR=`dirname "$0"`
[ ! -f "$CDIR/lib.sh" ] && echo "ERROR: Library file not found, abort!" && exit 1
. "$CDIR/lib.sh"

VIDEO_FILE="$1"
[ "x$VIDEO_FILE" == "x" ] && log "ERROR: Video file not exists." && exit 1
VIDEO_DIRECTORY="`dirname "$VIDEO_FILE"`"
VIDEO_FILE_NAME="`basename "$VIDEO_FILE"`"
VIDEO_FILE_MAINNAME=${VIDEO_FILE_NAME%.*}

SUBTITLES_FOUND=0
for IEXT in ${SUBTITLE_FILE_EXTENSIONS//|/ }; do
	if [ `ls "$VIDEO_DIRECTORY/$VIDEO_FILE_MAINNAME".$IEXT 2>/dev/null|wc -l` -gt 0 ]; then
		exit 1
	fi
	if [ `ls "$VIDEO_DIRECTORY/$VIDEO_FILE_MAINNAME".*.$IEXT 2>/dev/null|wc -l` -gt 0 ]; then
		exit 1
	fi
done

if [ "$SUBTITLES_FOUND" == "0" ]; then
	for IDIR in ${IGNORED_DIRECTORIES//|/ }; do
		for IEXT in ${SUBTITLE_FILE_EXTENSIONS//|/ }; do
			if [ `ls "$VIDEO_DIRECTORY"/$IDIR/*.$IEXT 2>/dev/null|wc -l` -gt 0 ]; then
				exit 1
			fi
		done
	done
fi

exit 0
