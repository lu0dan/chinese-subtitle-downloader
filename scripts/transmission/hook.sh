#!/bin/bash
# ---------------------------------------------------------
# Subtitle downloader trigger script for Transmission
# by luodan@gmail.com
# v0.9.1 2015.08.14
# ---------------------------------------------------------

[ "x$TR_TORRENT_NAME" != "x" ] && `dirname "$0"`/../../subtitle.sh -r -v -o "$TR_TORRENT_DIR/$TR_TORRENT_NAME"
