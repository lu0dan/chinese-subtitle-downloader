#!/bin/bash
# --------------------------------------------------
# Download the first subtitle from the sub list file
# by luodan@gmail.com
# v0.9 2015.08.12
# --------------------------------------------------

CDIR=`dirname "$0"`
[ ! -f "$CDIR/lib.engines.sh" ] && echo ERROR: Subtitle engine library file not found, abort! && exit 1
. "$CDIR/lib.engines.sh"

[ ! -f "$RATE_FILE" ] && exit 1

SUB_COUNT=`cat "$RATE_FILE" 2>/dev/null|wc -l|awk '{print $1;}'`
if [ $SUB_COUNT -gt 0 ]; then
	export DOWNLOAD_URL=`head -n1 "$RATE_FILE"|awk '{print $1}'`
	export DOWNLOAD_ENGINE=`head -n1 "$RATE_FILE"|awk '{print $3}'`
	RATE=`head -n1 "$RATE_FILE"|awk '{print $4}'`
	if [ ${RATE%%.*} -lt $RATE_THRESHOLD ]; then
		log "Found $SUB_COUNT relative subtitles, but they all seem not quite fit. The highest rate is: $RATE"
		exit 1
	else
		log "Found $SUB_COUNT relative subtitles. Pick the URL: $DOWNLOAD_URL, the score is: $RATE"

		# generate nfo file
		NFO_FILE="$DOWNLOAD_DIRECTORY/$NFO_FILE_NAME"
		echo "# ------------------------------------------------------------------------" > "$NFO_FILE"
		echo "# Subtitle downloaded by Chinese Subtitle Downloader (by luodan@gmail.com)" >> "$NFO_FILE"
		echo "#" >> "$NFO_FILE"
		echo "# Download from: $DOWNLOAD_URL" >> "$NFO_FILE"
		echo "# Download time: `date "+%Y-%m-%d %H:%M:%S"`" >> "$NFO_FILE"
		echo "# ------------------------------------------------------------------------" >> "$NFO_FILE"
		echo "# H A P P I N E S S   E V E R Y D A Y !" >> "$NFO_FILE"
		if [ $SUB_COUNT -gt 1 ]; then
			echo >> "$NFO_FILE"
			echo "If you find the subtitle is not correct or perfect, " >> "$NFO_FILE"
			echo "you can try find some other subtitles with download links and descrptions list below" >> "$NFO_FILE"
			echo >> "$NFO_FILE"
			cat $RATE_FILE|awk '{gsub(/\+/," ",$2);print $1,$2;}' >> "$NFO_FILE"
		fi
	fi
else
	log "ERROR: No subtitle downlad link found."
	exit 1
fi

# start downloading
[ "x$DOWNLOAD_URL" == "x" ] && log "No page about the video file found." && exit 1
[ "x$DOWNLOAD_ENGINE" == "x" -o ! -x "$CSD_SCRIPTS_DIRECTORY/download_${DOWNLOAD_ENGINE}.sh" ] && log "No download engine found?!" && exit 1
"$CSD_SCRIPTS_DIRECTORY/download_${DOWNLOAD_ENGINE}.sh"
exit 0
