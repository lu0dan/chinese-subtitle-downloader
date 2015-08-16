#!/bin/bash
# -----------------------------------------------------------
# Install Chinese Subtitle Downloader to transmission-daemon
# by luodan@gmail.com
# v0.9.1 2015.08.14
# -----------------------------------------------------------

get_transmission_line ()
{
	TRANSMISSION_LINE=`$PS_COMMAND|grep 'transmission-daemon'|grep -v 'grep'`
}

CDIR=`dirname "$0"`
PS_COMMAND="ps" && [ `ps|wc -l` -lt 10 ] && export PS_COMMAND="ps aux"
HOOK_SCRIPT="`(cd "$CDIR"; pwd;)`/hook.sh"
TEMP_SETTING_FILE="$CDIR/transmission.setup"

FORCE_MODE=0
[ "$1" == "-f" ] && FORCE_MODE=1

if [ "`whoami`" != "root" ]; then
	echo "Root is required to run this script."
	exit 1
fi

TRANSMISSION_DIR=
TRANSMISSION_SERVICE_SCRIPT=
echo -n Finding transmission service script ...
if [ -d /etc/init.d ]; then
	TRANSMISSION_SERVICE_SCRIPT=`ls -1 /etc/init.d|grep transmission|head -n 1`
fi
if [ "$TRANSMISSION_SERVICE_SCRIPT" == "" ]; then
	echo not found. You may have to start/stop transmission manually when prompts.
else
	echo found.
	TRANSMISSION_SERVICE_SCRIPT="/etc/init.d/$TRANSMISSION_SERVICE_SCRIPT"
fi

echo -n Finding transmission directory ...
[ -f "$TEMP_SETTING_FILE" ] && . "$TEMP_SETTING_FILE"
if [ "$TRANSMISSON_DIR" == "" ]; then
	# if transmission dir not set by the temp setting file, try to find it
	get_transmission_line                                                        
	if [ "$TRANSMISSION_LINE" == "" ]; then
		echo -n transmision not running ...
		if [ "$TRANSMISSION_SERIVCE_SCRIPT" != "" ]; then
			# try start transmission
			echo
			echo "Try to get transmission directory by start/stop service."
			$TRANSMISSION_SERVICE_SCRIPT start
			get_transmission_line
			$TRANSMISSION_SERVICE_SCRIPT stop
			echo -n "Try to find transmission directory again ..."
		fi
	fi
	
	[ "x$TRANSMISSION_LINE" != "x" ] && TRANSMISSION_DIR=`echo $TRANSMISSION_LINE|awk '{for (i = 1; i < NF; i++) { if ( $i == "-g" || $i == "--config-dir" ) print $(i+1);}}'`
	[ "x$TRANSMISSION_DIR" != "x" ] && echo "TRANSMISSION_DIR=\"$TRANSMISSION_DIR\"" > $TEMP_SETTING_FILE
fi

if [ "$TRANSMISSION_DIR" == "" ]; then
	echo transmission not found.
	echo
	echo "ERROR: Can not find transmission setting dir. Please start transmission and run this script again."
	echo "If still got this error, please make sure transmission is running by use PS command."
	echo
	exit 1
fi
echo found.

echo -n Finding transmission setting file ...
if [ ! -f $TRANSMISSION_DIR/settings.json ]; then
	echo not found.
	echo
	echo ERROR: Please make sure setting file exists: $TRANSMISSION_DIR/settings.json.
        echo
        exit 1
fi

echo found.

# transmission settings
echo -n Checking transmission setting ...
TRANSMISSION_SETTING=$TRANSMISSION_DIR/settings.json

ITEM1_MATCH="`cat $TRANSMISSION_SETTING|grep '"script-torrent-done-filename"'|awk 'BEGIN {FS=":";} {m=match($2, /"[^"]+"/)?substr($2, RSTART, RLENGTH):""; print m;}'`"
ITEM2_MATCH="`cat $TRANSMISSION_SETTING|grep '"script-torrent-done-enabled"'|awk 'BEGIN {FS=":";} {m=match($2, /[a-z]+/)?substr($2, RSTART, RLENGTH):""; print (m=="true") ? 1 : 0;}'`"

if [ "$ITEM2_MATCH" == "1" ]; then
	echo set
else
	echo not set
fi

if [ "x$ITEM1_MATCH" != "x" ]; then
	echo
	echo "WARNNING: transmission setting \"script-torrent-done-filename\" has been set to $ITEM1_MATCH"
	if [ "$FORCE_MODE" == "1" ]; then
		echo "Will force change to current subtitle downloader, due to the option \"-f\""
	else
		echo "If you want to overwrite this setting to current subtitle downloader, please use \"-f\" option"
		exit 1
	fi
fi

echo -n Checking transmission  ...
get_transmission_line
if [ "$TRANSMISSION_LINE" != "" ]; then
	echo running. Need to stop it.
	if [ "$TRANSMISSION_SERVICE_SCRIPT" != "" ] ; then
		echo Stopping transmission...
		$TRANSMISSION_SERVICE_SCRIPT stop
		get_transmission_line
		echo -n Try checking again ...
	fi
fi
	
if [ "$TRANSMISSION_LINE" != "" ]; then
	echo
	echo ERROR: Transmission is running and can not be stopped by script. You need to stop transmission manually.
	echo
	exit 1
fi

echo OK.
			
echo -n Modifying setting file ...
	
# deleting items
sed -e "/script-torrent-done/d" -i "$TRANSMISSION_SETTING" 2>/dev/null
sed -e "/^{/a\ \ \ \ \"script-torrent-done-enabled\": true\," -i "$TRANSMISSION_SETTING" 2>/dev/null
sed -e "/^{/a\ \ \ \ \"script-torrent-done-filename\": \"$HOOK_SCRIPT\"\," -i "$TRANSMISSION_SETTING" 2>/dev/null
	
# fix json grammar
CHECK_ROW=`awk '{if ($0 == "}") print NR-1;}' $TRANSMISSION_SETTING`
sed -e "$CHECK_ROW s/, *$//" -i "$TRANSMISSION_SETTING"

echo done.
	
rm -rf "$TEMP_SETTING_FILE"

if [ "$TRANSMISSION_SERVICE_SCRIPT" != "" ]; then
	echo Starting transmission...
	$TRANSMISSION_SERVICE_SCRIPT start
	echo
	echo Transmission setting has been set.
else
	echo
	echo Transmission setting has been set, you have to start transmission manually to take effects.
fi
echo !!! IMPORTANT !!!
echo Make sure the directory [`cd "$CDIR"; cd ../../; pwd`/log] has enough privilleges to let transmission daemon writes log in it.

exit

