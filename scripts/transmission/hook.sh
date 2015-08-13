#!/bin/bash
# ---------------------------------------------------------
# Subtitle downloader tigger script for Transmission
# by luodan@gmail.com
# v0.9 2015.08.12
# ---------------------------------------------------------

#echo `date` "$TR_TORRENT_DIR/$TR_TORRENT_NAME" >> `dirname "$0"`/log.log
[ "x$TR_TORRENT_NAME" != "x" ] && `dirname "$0"`/../../subtitle.sh -r -v -l "$TR_TORRENT_DIR/$TR_TORRENT_NAME"
