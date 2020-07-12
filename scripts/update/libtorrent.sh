#!/bin/bash
# Update for new libtorrent package
# by ajvulcan
# SERVIDOR HD

if [[ -f /install/.deluge.lock ]]; then
    if [[ ! -f /install/.libtorrent.lock ]]; then
        touch /install/.libtorrent.lock
    fi
fi