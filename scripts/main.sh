#!/bin/bash
# -------------------------------------------
# Main process of video file
# by luodan@gmail.com
# v0.9 2015.08.12
# -------------------------------------------

CDIR=`dirname "$0"`
[ ! -f "$CDIR/lib.engines.sh" ] && echo "ERROR: Subtitle engine library file not found, abort!" && exit 1
. "$CDIR/lib.engines.sh"

export VIDEO_FILE="$1"

if [ "x$VIDEO_FILE" == "x" -o ! -f "$VIDEO_FILE" ]; then
	log "ERROR: Video file not found, abort!"
	exit 1
fi

if ! is_video $VIDEO_FILE; then
	log "ERROR: The file is not a video file, abort."
	exit 1
fi

export VIDEO_DIRECTORY=`dirname "$VIDEO_FILE"`
export VIDEO_FILE_NAME=`basename "$VIDEO_FILE"`
export VIDEO_FILE_MAINNAME=${VIDEO_FILE_NAME%.*}
export FINDER_LIST_FILE="$CSD_TEMP_DIRECTORY/finder.$VIDEO_FILE_NAME.txt"
export RATE_FILE="$CSD_TEMP_DIRECTORY/rate.$VIDEO_FILE_NAME.txt"
export DOWNLOAD_DIRECTORY="$CSD_TEMP_DIRECTORY/download.$VIDEO_FILE_NAME"

rm -rf "$FINDER_LIST_FILE"
for ENGINE in "$CSD_SCRIPTS_DIRECTORY"/finder_*.sh; do
	if [ -x "$ENGINE" ]; then
		"$ENGINE"
	fi
done

FINISH=0
mkdir -p "$DOWNLOAD_DIRECTORY"
"$CSD_SCRIPTS_DIRECTORY/calc_rate.sh" && \
"$CSD_SCRIPTS_DIRECTORY/download.sh"   && \
"$CSD_SCRIPTS_DIRECTORY/unpack.sh"     && \
"$CSD_SCRIPTS_DIRECTORY/cleanup.sh"    && \
FINISH=1
#rm -rf "$DOWNLOAD_DIRECTORY"
[ "$FINISH" == "0" ] && exit 1
exit 0

