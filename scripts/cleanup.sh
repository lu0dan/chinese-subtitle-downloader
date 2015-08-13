#!/bin/bash
# -------------------------------------------
# Cleanup and move files to video directory
# by luodan@gmail.com
# v0.9 2015.08.12
# -------------------------------------------

CDIR=`dirname "$0"`
[ ! -f "$CDIR/lib.sh" ] && echo ERROR: Common library file not found, abort! && exit 1
. "$CDIR/lib.sh"

[ "x$DOWNLOAD_DIRECTORY" == "x" -o ! -d "$DOWNLOAD_DIRECTORY" -o ! -w "$DOWNLOAD_DIRECTORY" ] && log "ERROR: Download directory not found or not accessable." && exit 1
[ ! -f "$VIDEO_FILE" -o ! -w "$VIDEO_DIRECTORY"  ] && log "ERROR: Video file or directory not exist or not accessable." && exit 1


# 1. Clean up non-subtitle and non-packed files.

for FILE_IN_LIST in "$DOWNLOAD_DIRECTORY"/*; do
	[ "`echo "$FILE_IN_LIST"|awk '{print match($0, /\.('$SUBTITLE_FILE_EXTENSIONS'|'$PACKED_FILE_EXTENSIONS'|nfo)$/)?1:0}'`" != "1" ] &&  rm -rf "$FILE_IN_LIST"
done

# 2. Find longest text in subtitle files

if [ `ls -1 "$DOWNLOAD_DIRECTORY"|wc -l` -gt 0 ]; then

	INTERSECTION=`ls -1 "$DOWNLOAD_DIRECTORY"|grep -v "$NFO_FILE_NAME"|awk 'BEGIN{FS=".";}{for(i=1;i<NF;i++){if(NR==1){s[i]=$i;p=i;}else{if(s[i]!=$i){p=i-1;break;}}}if(i<=p)p=i-1;}END{n="";for(i=1;i<=p;i++)n=n s[i]".";print substr(n,1,length(n)-1);}'`

	for FILE_IN_LIST in "$DOWNLOAD_DIRECTORY"/*; do
		FILE_IN_LIST_BASENAME=`basename "$FILE_IN_LIST"`
		if [ "$FILE_IN_LIST_BASENAME" == "$NFO_FILE_NAME" ]; then
			mv -f "$FILE_IN_LIST" "$VIDEO_DIRECTORY"
		else
			if [ "x$INTERSECTION" == "x" ]; then
				mv -f "$FILE_IN_LIST" "$VIDEO_DIRECTORY/$VIDEO_FILE_MAINNAME.${FILE_IN_LIST_BASENAME#*.}"
			else
				FINAL_NAME="${FILE_IN_LIST_BASENAME/$INTERSECTION./$VIDEO_FILE_MAINNAME.}"
				mv -f "$FILE_IN_LIST" "$VIDEO_DIRECTORY/$FINAL_NAME"
			fi
		fi
	done
else
	log "No subtitle files found."
	exit 1
fi

exit
