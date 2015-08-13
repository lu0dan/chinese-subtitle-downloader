#!/bin/bash
# -------------------------------------------
# Subtitle downloader for zimuku.net
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

ENGINE_SITE=http://www.zimuku.net
CURL_FILE="$CSD_TEMP_DIRECTORY/detail.$MODEL_NAME.$VIDEO_FILE_NAME.html"
SUBTITLE_URL=
regularize_request_url "$DOWNLOAD_URL"
# Notice: Do not cache detail page, it will expire shortly.
log "Downloading subtitle from $ENGINE_SITE ..."
curl -A "$USER_AGENT" -k -s -o "$CURL_FILE" "$REQUEST_URL"
SUBTITLE_URL=`cat "$CURL_FILE"|grep "下载字幕"|awk '{print match($0, /href="[^"]+"/)?substr($0,RSTART,RLENGTH):"";}'|awk 'BEGIN{FS="\"";}{print $2;}'`
#rm -rf "$CURL_FILE"

# Download subtitle

[ "x$SUBTITLE_URL" == "x" ] && log "Video page founded, but no subtitle URL found." && exit 1

regularize_request_url "$SUBTITLE_URL"

( cd "$DOWNLOAD_DIRECTORY"; curl --connect-timeout $CONNECT_TIMEOUT -A "$USER_AGENT" -k -s -O -J "$REQUEST_URL"; )

# Notice: curl has no overwrite checking for -O or -J, so I can't know if it's downloaded successfully when there is already same file exists.
log "Subtitle (or packed file) downloaded."

exit 0
