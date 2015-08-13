#!/bin/bash
# -----------------------------------------
# Chinese Subtitle Finder
# by luodan@gmail.com
# v0.9 2015.08.12
# -----------------------------------------

V=0.9

subtitle_title(){
	if [ "$CSD_LOG_LEVEL" != "1" ]; then
		echo Chinese Subtitle Finder $V
		echo by luodan@gmail.com
		echo
	fi
}

subtitle_usage(){
	log Usage: subtitle [-rolfv] path or video file name [path or video file name ...]
	log
	log Options are:
	log "-r : Process directory recursively."
	log "-o : Send messages to log file, instead of displaying on screen (sending to stdout)."
	log "-l : List all the video files need to download subtitles. If -f presents, list all video files."
	log "     With \"-l\", verbose mode \"-v\" is automatically set off. Script title and summary information will *NOT* display either."
	log "-f : Force to find subtitles. (Default: Skip finding subtitles if subtitles already exist.)"
	log "-v : Verbose mode. (Default: Only display information about the video file which needs to download subtitle)"
	log
}

subtitle_summary(){
	log
	log "        S U M M A R Y"
	log "-----------------------------"
	log "        Files processed: $FILES_PROCESSED"
	log "   Subtitles downloaded: $SUBTITLES_DOWNLOADED"
	log "  Directories processed: $DIRECTORIES_PROCESSED"
	log "    Directories skipped: $DIRECTORIES_SKIPPED"
	log "          Files skipped: $FILES_SKIPPED"
	log
}

process()
{
	local TARGET=${@%/}
	TARGET_BASENAME=`basename "$TARGET"`
	if [ -d "$TARGET" ]; then
		if [ -f "$TARGET/$IGNORED_DIRECTORY_ID_FILE" ]; then
			[ $VERBOSE_MODE -eq 1 ] && log "Skipping directory [$TARGET_BASENAME] ... \"$IGNORED_DIRECTORY_ID_FILE\" found."
			let DIRECTORIES_SKIPPED=$DIRECTORIES_SKIPPED+1
		elif [ `echo "$TARGET_BASENAME"|awk '{print match($0,/^('$IGNORED_DIRECTORIES')$/)?1:0;}'` -eq 1 ]; then
			[ $VERBOSE_MODE -eq 1 ] && log "Skipping directory [$TARGET_BASENAME] ... Ignored directories."
			let DIRECTORIES_SKIPPED=$DIRECTORIES_SKIPPED+1
		else
			[ $VERBOSE_MODE -eq 1 ] && log "Processing directory [$TARGET_BASENAME] ..."
			if [ "`ls -1 "$TARGET"|wc -l`" -gt 0 ]; then
				local FILE_NAME=
				for FILE_NAME in "$TARGET"/*; do
					process $FILE_NAME
				done
			fi
			let DIRECTORIES_PROCESSED=$DIRECTORIES_PROCESSED+1
		fi
	elif [ -f "$TARGET" ]; then
		if ! is_video "$TARGET_BASENAME"; then
			[ $VERBOSE_MODE -eq 1 ] && log "Skipping file [$TARGET_BASENAME] ... Not a video file."
			let FILES_SKIPPED=$FILES_SKIPPED+1
		elif echo "$TARGET_BASENAME"|grep -q -E "($IGNORED_FILES)"; then
			[ $VERBOSE_MODE -eq 1 ] && log "Skipping file [$TARGET_BASENAME] ... Igonred file."
			let FILES_SKIPPED=$FILES_SKIPPED+1
		elif [ "$FORCE_MODE" == "1" ] || "$CSD_SCRIPTS_DIRECTORY/check_subtitle.sh" "$TARGET"; then
			if [ "$LIST_MODE" == "1" ]; then
				log "$TARGET"
			else
				log "Processing file [$TARGET_BASENAME] ..."
				"$CSD_SCRIPTS_DIRECTORY"/main.sh "$TARGET" && let SUBTITLES_DOWNLOADED=$SUBTITLES_DOWNLOADED+1
			fi
			let FILES_PROCESSED=$FILES_PROCESSED+1
		else
			[ "$VERBOSE_MODE" -eq 1 ] && log "Skipping file [$TARGET_BASENAME] ... Already has subtitles."
			let FILES_SKIPPED=$FILES_SKIPPED+1
		fi
	else
		[ $VERBOSE_MODE -eq 1 ] && log "Skipping [$TARGET_BASENAME] ... Not a directory nor a file?!"
	fi
}

CDIR=`dirname "$0"`
[ ! -f "$CDIR/scripts/lib.sh" ] && echo ERROR: Libraray file not found, abort! && exit 1
. "$CDIR/scripts/lib.sh"

# Process args

RECURSIVE_MODE=0
FORCE_MODE=0
VERBOSE_MODE=0
LIST_MODE=0

for ARG in "$@"; do
	case "$ARG" in
		"-r")	RECURSIVE_MODE=1;;
		"-o")	export CSD_LOG_LEVEL=1;;
		"-l")	[ "$VERBOSE_MODE" == "1" ] && VERBOSE_MODE=0
			LIST_MODE=1
			;;
		"-f")	FORCE_MODE=1;;
		"-v")	[ "$LIST_MODE" != "1" ] && VERBOSE_MODE=1;;
		-*)
			log "Warning: Option \"$ARG\" is not supportted."
			log
			;;
	esac
done

# Process files/directories

DIRECTORIES_PROCESSED=0
DIRECTORIES_SKIPPED=0
FILES_PROCESSED=0
FILES_SKIPPED=0
SUBTITLES_DOWNLOADED=0

[ "$LIST_MODE" != "1" ] && subtitle_title

TARGET_COUNT=0
for ARG in "$@"; do
	if [ "${ARG:0:1}" != "-" ]; then
		process "$ARG"
		let TARGET_COUNT=$TARGET_COUNT+1
	fi
done

if [ "$TARGET_COUNT" == "0" -a "$LIST_MODE" != "1" ]; then
	subtitle_usage
	exit
fi

[ "$LIST_MODE" != "1" ] && subtitle_summary

# Finish and cleanup

rm -rf "$CSD_TEMP_DIRECTORY"

exit

