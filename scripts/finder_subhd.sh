#!/bin/bash
# -------------------------------------------
# Subtitle searcher for subhd.com
# by luodan@gmail.com
# v0.9 2015.08.12
# -------------------------------------------

CDIR=`dirname "$0"`

[ ! -f "$CDIR/lib.engines.sh" ] && echo "ERROR: Subtitle engine library file not found, abort!" && exit 1
. "$CDIR/lib.engines.sh"

ENGINE_SITE=http://subhd.com
SEARCH_URL_PREFIX="$ENGINE_SITE/search/"

filename_to_querystring "$VIDEO_FILE_NAME"
ORIGINAL_QUERY_STRING="$QUERY_STRING"

STOP_WORD=`echo "$QUERY_STRING"|awk -F"+" '{s=$1;if(tolower(s)=="the" && NF>1)s=$2;for (i=NF; i>1; i--) {if (match($i, /^(19|20)[0-9][0-9]$/)) {s=$i;}} print s;}'`  
#TVSHOW=`echo "$QUERY_STRING"|awk -F"+" '{for(i=1;i<=NF;i++){if (match($i,/^[Ss][01][0-9][Ee][0-9][0-9]$/))print $i;}}'|head -n1`
#TVSHOW_SEASON=${TVSHOW:1:2}
#TVSHOW_EPISODE=${TVSHOW:4:2}
#[ "x$TVSHOW" != "x" ] && log "Video file may be a TV show."

# 1. Find subs pages

log "Searching subtitles in $ENGINE_SITE ..."
STOP_REQUEST=0
LIST_FILE="$CSD_TEMP_DIRECTORY/pre-subs.$MODEL_NAME.$VIDEO_FILE_NAME.txt"
rm -rf "$LIST_FILE"

while [ "$STOP_REQUEST" == "0" ]
do
	CURL_FILE="$CSD_TEMP_DIRECTORY/search.$MODEL_NAME.${QUERY_STRING//+/-}.html"
	REQUEST_URL=$SEARCH_URL_PREFIX$QUERY_STRING
	[ ! -f "$CURL_FILE" ] && curl --connect-timeout $CONNECT_TIMEOUT -A "$USER_AGENT" -k -s -o "$CURL_FILE" "$REQUEST_URL"
	# old version with download link and desc
#	sed -n '1,/热门字幕/p' "$CURL_FILE"|grep -E '<a href="/a/[0-9]+" target="_blank">.*</a>'|awk '{s=match($0,/a href="[^"]+"/)?substr($0,RSTART+8,RLENGTH-9):"";t=match($0,/_blank">[^<]+</)?substr($0,RSTART+8,RLENGTH-9):"";if((s!="")&&(t!="")){gsub(/ /,"+",t);print "'$ENGINE_SITE'"s,t,"subhd";}}'>"$LIST_FILE"
	# new version with link, desc and label
	sed -n "/<div class=\"box\">/,/热门字幕/p" "$CURL_FILE"|awk 'BEGIN{l="";d="";}{if(match($0,/href="\/a\/[^"]+"/)){l=substr($0,RSTART+6,RLENGTH-7);if(match($0,/_blank">[^<]+</)){d=substr($0,RSTART+8,RLENGTH-9)}next;}if(match($0,/<!--/)){if((l!="")&&(d!="")){gsub(/ /,"+",d);print "'$ENGINE_SITE'"l,d,"subhd"}l="";d=""}t=$0;while(match(t,/<span class="label/)){if(match(t,/[^>]+<\/span>/)){d=d" "substr(t,RSTART,RLENGTH-7);};tr=index(t,"</span>");tr=(tr<1)?9999:tr+7;t=substr(t,tr,9999);}}END{if((l!="")&&(d!="")){gsub(/ /,"+",d);print "'$ENGINE_SITE'"l,d,"subhd";}}'>"$LIST_FILE"
	[ `cat "$LIST_FILE"|wc -l` -gt 0 ] && STOP_REQUEST=1

	# remove last word and continue search
	if [ "$STOP_REQUEST" == "0" ]; then
		NEXT_QUERY_STRING=${QUERY_STRING%+*}
		[ "x$STOP_WORD" != "x" -a "$QUERY_STRING" == "${QUERY_STRING%$STOP_WORD*}" ] && STOP_REQUEST=1 
		[ "$QUERY_STRING" == "$NEXT_QUERY_STRING" -o "x$NEXT_QUERY_STRING" == "x" ] && STOP_REQUEST=1
		QUERY_STRING=$NEXT_QUERY_STRING
	fi
done

if [ ! -f "$LIST_FILE" -o `cat "$LIST_FILE"|wc -l` -eq 0 ]; then
	log "Can't find any video about $VIDEO_FILE_NAME"
	exit 1
fi

cat "$LIST_FILE" >> "$FINDER_LIST_FILE"

log "Found `cat "$LIST_FILE"|wc -l|awk '{print $1;}'` subtitles in $ENGINE_SITE."

exit 0
