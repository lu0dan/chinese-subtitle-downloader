#!/bin/bash
# ------------------------------------
# Library file for subtitle engine
# by luodan@gmail.com
# v0.9 2015.08.12
# ------------------------------------

# This file should be include in every engine file, not run this along.

CDIR=`dirname "$0"`

if [ ! -f "$CDIR/lib.sh" ]; then
	echo ERROR: Subtitle library file not found, abort!
	exit 1
fi
. "$CDIR/lib.sh"

USER_AGENT="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_4) AppleWebKit/600.7.12 (KHTML, like Gecko) Version/8.0.7 Safari/600.7.12"
RATE_THRESHOLD=40
CONNECT_TIMEOUT=60

regularize_request_url() {
	# regularize URL to http://...
	REQUEST_URL="$1"
	if [ "${1:0:4}" != "http" ]; then
		REQUEST_URL="$ENGINE_SITE$REQUEST_URL"
	fi
}

filename_to_querystring() {
	QUERY_STRING=${1%.*} # rip extension
	QUERY_STRING=`echo "${QUERY_STRING//[ .\-_\)\(\[\]]/+}"|awk 'BEGIN{ORS="+";}{split($0,k,"+");for(i in k){k[i]=tolower(k[i]);if (match(k[i],/^(720p|1080p|4k|bd\-?rip|blu\-?ray|dts|hd|hdtv|[xh]264|the)$/)){}else{print k[i];}}}'`
	QUERY_STRING="${QUERY_STRING%+}"
}

generate_nfo() {
	# generate nfo file
	NFO_FILE="$DOWNLOAD_DIRECTORY/$NFO_FILE_NAME"
	echo "# ------------------------------------------------------------------------" > "$NFO_FILE"
	echo "# Subtitle downloaded by Chinese Subtitle Downloader (by luodan@gmail.com)" >> "$NFO_FILE"
	echo "#" >> "$NFO_FILE"
	echo "# Download from: $REQUEST_URL" >> "$NFO_FILE"
	echo "# Time: `date "+%Y-%m-%d %H:%M:%S"`" >> "$NFO_FILE"
	echo "# ------------------------------------------------------------------------" >> "$NFO_FILE"
	echo "# H A P P I N E S S   E V E R Y D A Y !" >> "$NFO_FILE"
	if [ $SUB_COUNT -gt 1 ]; then
		echo >> "$NFO_FILE"
		echo "If you find the subtitle is not correct or perfect, " >> "$NFO_FILE"
		echo "you can try find some other subtitles with download links and descrptions list below" >> "$NFO_FILE"
		echo >> "$NFO_FILE"
		cat $SUBLIST_FILE|sed -e "s#^/#$ENGINE_SITE/#" >> "$NFO_FILE"
	fi
}
