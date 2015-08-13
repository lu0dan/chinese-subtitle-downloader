#!/bin/bash
# ----------------------------------------------------------------------------------
# Unpack all files in download directory and remove them if they unpacked correctly.
# by luodan@gmail.com
# v0.9 2015.08.12
# ----------------------------------------------------------------------------------

unpack_file(){
	local SOURCE_FILE="$*"
	case "${SOURCE_FILE##*.}" in
	"zip"|"ZIP"|"Zip")
		if [ -z $ZIP_TOOL ]; then
			log "WARNNING: No unzip tool found. Unzip it manually."
		else
			$ZIP_TOOL -o -j -q "$SOURCE_FILE" -d "$DOWNLOAD_DIRECTORY" # there may be errors when extract chinese chars.
			rm -f "$SOURCE_FILE"
			log "Subtitle file unpacked with $ZIP_TOOL."
		fi
		;;
	"rar"|"RAR"|"Rar")
		if [ -z $RAR_TOOL ]; then
			log "WARNNING: No RAR tool found. Un-RAR it manually."
		else
			$RAR_TOOL e -o -inul "$SOURCE_FILE" "$DOWNLOAD_DIRECTORY"
			rm -f "$SOURCE_FILE"
			log "Subtitle file unpacked with $RAR_TOOL."
		fi
		;;
	$SUBTITLE_FILE_EXTENSIONS)
		#log "Already"
		:
		;;
	*)
		:
		#log "WARNNING: File type not recognized. Please handle it manually."
		;;
	esac
}

CDIR=`dirname "$0"`
[ ! -f "$CDIR/lib.sh" ] && echo "ERROR: Common library file not found, abort!" && exit 1
. "$CDIR/lib.sh"

[ "x$DOWNLOAD_DIRECTORY" == "x" ] && log "ERROR: No source file or directory set." && exit 1

RAR_TOOL=
is_command_available "rar" && RAR_TOOL=rar 
is_command_available "unrar" && RAR_TOOL=unrar
ZIP_TOOL=
is_command_available "unzip" && ZIP_TOOL=unzip

if [ -f "$DOWNLOAD_DIRECTORY" ]; then
	# WILL NOT execute for current mechanism
	unpack_file "$DOWNLOAD_DIRECTORY"
elif [ -d "$DOWNLOAD_DIRECTORY" ]; then
	for PACKED_FILE in "$DOWNLOAD_DIRECTORY"/*; do
		unpack_file "$PACKED_FILE"
	done
else
	log "ERROR: Source file not exist or not accessable."
	exit 1
fi

exit
