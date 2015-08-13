#!/bin/bash
# -------------------------------------------
# Subtitle downloader for subhd.com
# by luodan@gmail.com
# v0.9 2015.08.12
# -------------------------------------------

CDIR=`dirname "$0"`
[ ! -f "$CDIR/lib.engines.sh" ] && echo "ERROR: Subtitle engine library file not found, abort!" && exit 1
. "$CDIR/lib.engines.sh"

[ "x$DOWNLOAD_URL" == "x" ] && log "ERROR: Detail page URL not found, abort!" && exit 1

if [ "x$DOWNLOAD_DIRECTORY" == "x" -o ! -d "$DOWNLOAD_DIRECTORY" -o ! -w "$DOWNLOAD_DIRECTORY" ]; then
	log "ERROR: Download directory not found or not accessable, abort."
	exit 1
fi

ENGINE_SITE=http://subhd.com
CURL_FILE="$CSD_TEMP_DIRECTORY/detail.$MODEL_NAME.$VIDEO_FILE_NAME.html"
SUBTITLE_ID="${DOWNLOAD_URL##*/}"
log "Download subtitle from $ENGINE_SITE ..."
[ ! -f "$CURL_FILE" ] && curl --connect-timeout $CONNECT_TIMEOUT -s -o "$CURL_FILE" -A "$USER_AGENT" -e "$DOWNLOAD_URL" -d "sub_id=$SUBTITLE_ID" "http://subhd.com/ajax/down_ajax"
SUBTITLE_URL="`cat "$CURL_FILE"|awk '{s="";if (match($0,/"url":"[^"]+"/)){s=substr($0,RSTART+7,RLENGTH-8);}gsub(/\\\\/,"",s);print s;}'`"
#rm -rf "$CURL_FILE"

# Download subtitle

[ "x$SUBTITLE_URL" == "x" ] && log "Video page founded, but no subtitle URL found." && exit 1

regularize_request_url "$SUBTITLE_URL"

( cd "$DOWNLOAD_DIRECTORY"; curl --connect-timeout $CONNECT_TIMEOUT -A "$USER_AGENT" -k -s -O -J "$REQUEST_URL"; )

# Notice: curl has no overwrite checking for -O or -J, so I can't know if it's downloaded successfully when there is already same file exists.
log "Subtitle (or packed file) downloaded."

exit 0
