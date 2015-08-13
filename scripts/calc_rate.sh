#!/bin/bash
# -------------------------------------------
# Calc subtitle rate from finder list
# by luodan@gmail.com
# v0.9 2015.08.12
# -------------------------------------------

CDIR=`dirname "$0"`
[ ! -f "$CDIR/lib.engines.sh" ] && echo "ERROR: Subtitle engine library file not found, abort!" && exit 1
. "$CDIR/lib.engines.sh"

[ ! -f "$FINDER_LIST_FILE" ] && log "ERROR: No engine search results." && exit 1

filename_to_querystring "$VIDEO_FILE_NAME"
cat "$FINDER_LIST_FILE"|awk 'BEGIN{split("'$QUERY_STRING'",w,"+");n=0;for(i in w){w[i]=tolower(w[i]);n++;}if(n==0)exit;}{s=$2;gsub(/[ ._\/\)\(\[\-]+/,"+",s);split(s,k,"+");for (i in k){k[i]=tolower(k[i]);}m=0;for(j in k){if(k[j]=="chs"||k[j]=="cn")m+=1.2;if(k[j]=="cht")m+=1.1;for(i in w){if((w[i]!="")&&(w[i]==k[j]))m++;}}print $1,$2,$3,m*100/n;}'|sort -nr -k4>"$RATE_FILE"

exit 0
