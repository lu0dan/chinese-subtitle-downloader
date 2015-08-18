#!/bin/bash
# -------------------------------------------
# Calc subtitle rate from finder list
# by luodan@gmail.com
# v0.9 2015.08.12
# -------------------------------------------

CDIR=`dirname "$0"`
[ ! -f "$CDIR/lib.engines.sh" ] && echo "ERROR: Subtitle engine library file not found, abort!" && exit 1
. "$CDIR/lib.engines.sh"
[ -f "$CSD_DIRECTORY/engines.conf" ] && . "$CSD_DIRECTORY/engines.conf"

# export engine amp factors
for ENGINE_NAME in "$CSD_SCRIPTS_DIRECTORY"/finder_*; do
	ENGINE_NAME=${ENGINE_NAME##*_}
	ENGINE_NAME=`echo ${ENGINE_NAME%%.*}|tr '[a-z]' '[A-Z]'`
	VAR_NAME="ENGINE_AMP_FACTOR_$ENGINE_NAME"
	eval VAR_VALUE=\$$VAR_NAME
	unset $VAR_NAME
	if [ "x$VAR_VALUE" != "x" ]; then
		export $VAR_NAME=$VAR_VALUE
	fi
done

[ ! -f "$FINDER_LIST_FILE" ] && log "ERROR: No engine search results." && exit 1

filename_to_querystring "$VIDEO_FILE_NAME"
# old version with kw chs/cht check
#cat "$FINDER_LIST_FILE"|awk 'BEGIN{split("'$QUERY_STRING'",w,"+");n=0;for(i in w){w[i]=tolower(w[i]);n++;}if(n==0)exit;}{s=$2;gsub(/[ ._\/\)\(\[\-]+/,"+",s);split(s,k,"+");for (i in k){k[i]=tolower(k[i]);}m=0;for(j in k){if(k[j]=="chs"||k[j]=="cn")m+=1.2;if(k[j]=="cht")m+=1.1;for(i in w){if((w[i]!="")&&(w[i]==k[j]))m++;}}"echo $ENGINE_AMP_FACTOR_"toupper($3)|getline f;if(f=="")f=1;print $1,$2,$3,m*f*100/n,n,m,f;}'|sort -nr -k4>"$RATE_FILE"

# new version with kw chs/cht/中文/英文... check
cat "$FINDER_LIST_FILE"|awk 'BEGIN{split("'$QUERY_STRING'",w,"+");n=0;se="";for(i in w){w[i]=tolower(w[i]);if(match(w[i],/^s[0-9][0-9]e[0-9][0-9]$/))se=w[i];n++;}if(n==0)exit;}{s=$2;gsub(/[ ._\/\)\(\[\-]+/,"+",s);split(s,k,"+");for (i in k){k[i]=tolower(k[i]);if((se!="")&&(match(k[i],/^s[0-9][0-9]e[0-9][0-9]$/))&&(k[i]!=se))next;}m=0;amp=1;for(j in k){if(k[j]=="chs"||k[j]=="cn"||index(k[j],"中文")>0||index(k[j],"简体")>0||index(k[j],"双语")>0)amp*=1.2;if(k[j]=="cht"||index(k[j],"繁体")>0)amp*=1.1;if(index(k[j],"英文")>0)amp*=0.92;for(i in w){if((w[i]!="")&&(w[i]==k[j]))m++;}}"echo $ENGINE_AMP_FACTOR_"toupper($3)|getline f;if(f=="")f=1;r=m*f*amp*100/n;if(r>0)print $1,$2,$3,m*f*amp*100/n,n,m,f,amp;}'|sort -nr -k4>"$RATE_FILE"

exit 0
