#!/bin/sh
set -x
set -e

MY_IP=`ip -4 address show scope global | awk '/inet/ {print $2}' | cut -d'/' -f1 | head -n1`
sed -i -e "s/MY_IP/$MY_IP/g" /etc/rtpengine.conf
sed -i -e "s/PUBLIC_IP/$PUBLIC_IP/g" /etc/rtpengine.conf

rtpengine --config-file /etc/rtpengine.conf  "$@"


