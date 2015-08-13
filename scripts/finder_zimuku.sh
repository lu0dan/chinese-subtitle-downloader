#!/bin/bash
# -------------------------------------------
# Subtitle searcher for zimuku.net
# by luodan@gmail.com
# v0.9 2015.08.12
# -------------------------------------------

CDIR=`dirname "$0"`

[ ! -f "$CDIR/lib.engines.sh" ] && echo "ERROR: Subtitle engine library file not found, abort!" && exit 1
. "$CDIR/lib.engines.sh"

ENGINE_SITE=http://www.zimuku.net
SEARCH_URL_PREFIX="$ENGINE_SITE/search?q="

filename_to_querystring "$VIDEO_FILE_NAME"
ORIGINAL_QUERY_STRING="$QUERY_STRING"

STOP_WORD=`echo "$QUERY_STRING"|awk -F"+" '{s=$1;if(tolower(s)=="the" && NF>1)s=$2;for (i=NF; i>1; i--) {if (match($i, /^(19|20)[0-9][0-9]$/)) {s=$i;}} print s;}'`  
#TVSHOW=`echo "$QUERY_STRING"|awk -F"+" '{for(i=1;i<=NF;i++){if (match($i,/^[Ss][01][0-9][Ee][0-9][0-9]$/))print $i;}}'|head -n1`
#TVSHOW_SEASON=${TVSHOW:1:2}
#TVSHOW_EPISODE=${TVSHOW:4:2}
#[ "x$TVSHOW" != "x" ] && log "Video file may be a TV show."

# 1. Find subs pages

log "Searching subtitle form $ENGINE_SITE ..."
STOP_REQUEST=0
LIST_FILE="$CSD_TEMP_DIRECTORY/pre-subs.$MODEL_NAME.$VIDEO_FILE_NAME.txt"
rm -rf "$LIST_FILE"

while [ "$STOP_REQUEST" == "0" ]
do
	CURL_FILE="$CSD_TEMP_DIRECTORY/search.$MODEL_NAME.${QUERY_STRING//+/-}.html"
	REQUEST_URL=$SEARCH_URL_PREFIX$QUERY_STRING
	[ ! -f "$CURL_FILE" ] && curl --connect-timeout $CONNECT_TIMEOUT -A "$USER_AGENT" -k -s -o "$CURL_FILE" "$REQUEST_URL"
	RECORDS_FOUND=`grep "共 [0-9]\+ 条记录" "$CURL_FILE"|head -n1|awk '{s=match($0, /共 [0-9]+ 条记录/)?substr($0, RSTART, RLENGTH):""; s=match(s, /[0-9]+/)?substr(s, RSTART, RLENGTH):""; print s;}'`
	if [ "x$RECORDS_FOUND" != "x" -a $RECORDS_FOUND -gt 0 ]; then
		STOP_REQUEST=1
		sed -n "/条记录/,/条记录/p" "$CURL_FILE"|grep -E "(class=\"title\"|/subs/[0-9]+.html|href=\"/[^\"]+\" title|还有[0-9]+个字幕)"|awk 'BEGIN{i=0;p=-1;s="";rb=0;}{if (index($0, "class=\"title\"")>0){if(rb==1){a[p]=s;i=p+1;}rb=0;s="";p=i}if(match($0,/\/subs\/[0-9]+.html/)){if (s==""){s=substr($0,RSTART,RLENGTH);}}if(match($0,/href="[^"]+" title="[^"]+"/)){a[i]=substr($0,RSTART,RLENGTH);i++}if(match($0,/还有[0-9]+个字幕/)){rb=1;}}END{if(rb==1){a[p]=s;i=p+1;}for(j=0;j<i;j++) print a[j]}' > "$LIST_FILE"
		# check if $LIST_FILE has records, if not, continue to try shooter mode
		if [ `cat "$LIST_FILE"|wc -l` -eq 0 ]; then
			sed -n "/条记录/,/条记录/p" "$CURL_FILE"|grep -E "/(shooter|detail)/[0-9]+.html"|awk '{s=match($0,/href=\"\/(shooter|detail)\/[0-9]+.html\"/)?substr($0,RSTART,RLENGTH):"";t=match($0,/<b>.+<\/b>/)?substr($0,RSTART,RLENGTH):""; print s,"title=\""substr(t,4,length(t)-7)"\"";}' > "$LIST_FILE"
		fi
	fi

	# remove last word and continue search
	if [ "$STOP_REQUEST" == "0" ]; then
		NEXT_QUERY_STRING=${QUERY_STRING%+*}
		[ "x$STOP_WORD" != "x" -a "$QUERY_STRING" == "${QUERY_STRING%$STOP_WORD*}" ] && STOP_REQUEST=1 
		[ "$QUERY_STRING" == "$NEXT_QUERY_STRING" -o "x$NEXT_QUERY_STRING" == "x" ] && STOP_REQUEST=1
		QUERY_STRING=$NEXT_QUERY_STRING
	fi
done

# 2. expand /subs/xxx.html to subtitle list

if [ ! -f "$LIST_FILE" ]; then
	log "Can't find any video about $VIDEO_FILE_NAME"
	exit 1
fi
 
SUBLIST_FILE="$CSD_TEMP_DIRECTORY/sublist.$MODEL_NAME.$VIDEO_FILE_NAME.txt"
rm -rf "$SUBLIST_FILE"
{
	read line
	while [ "$line" != "" ]; do
		if [ ${line:0:1} == "/" ]; then
			CURL_FILE="$CSD_TEMP_DIRECTORY/$MODEL_NAME.$VIDEO_FILE_NAME.${line##*/}.subs.html"
			regularize_request_url "$line"
			[ ! -f "$CURL_FILE" ] && curl --connect-timeout $CONNECT_TIMEOUT -A "$USER_AGENT" -k -s -o "$CURL_FILE" "$REQUEST_URL"
			sed -n "/moviedteail_img/,/底部/p" "$CURL_FILE"|grep -E "/subs/[0-9]+.html|href=\"/[^\"]+\" title"|awk '{if(match($0,/href="[^"]+" title="[^"]+"/))print substr($0,RSTART,RLENGTH);}' >> "$SUBLIST_FILE"
		else
			echo "$line" >> "$SUBLIST_FILE"
		fi
		read line
	done
} < "$LIST_FILE"
#rm -rf "$LIST_FILE"

# regularize sublist file.
[ -f "$SUBLIST_FILE" ] && cat "$SUBLIST_FILE"|sed -e "s/\"//g" -e "s/ /\+/g" -e "s/^href=//g" -e "s/+title=/ /g"|awk '{print ((substr($1,1,1)=="/")?"'$ENGINE_SITE'":"")$1,$2,"zimuku"}' >> "$FINDER_LIST_FILE"

log "Found `cat "$SUBLIST_FILE"|wc -l|awk '{print $1;}'` subtitles in $ENGINE_SITE."
#rm -rf "$SUBLIST_FILE"

exit 0
