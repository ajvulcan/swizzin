#!/bin/bash
<<<<<<< HEAD

if [[ -f /install/.znc.lock ]]; then
=======
#
# SERVIDOR HD
#

if [[ -f /install/.znc.lock ]]; then
    . /etc/swizzin/sources/functions/letsencrypt
    le_znc_hook
>>>>>>> master
    if [[ ! -s /install/.znc.lock ]]; then
        echo "$(grep Port /home/znc/.znc/configs/znc.conf | sed -e 's/^[ \t]*//')" > /install/.znc.lock
        echo "$(grep SSL /home/znc/.znc/configs/znc.conf | sed -e 's/^[ \t]*//')" >> /install/.znc.lock
    fi
<<<<<<< HEAD
fi 
=======
fi
>>>>>>> master
