#!/bin/sh

######################################################################
#
#  ip-display: show ip address to AQM0802 if connected
#  Version: 0.0.2
#  Written by Shoji Iwaura (xshell inc) at 2018/02/23
#
# Usage  : ./aqm-ip-display.sh
#
# * If connected AQM0802. desplay my IPaddress.
# * http://akizukidenshi.com/catalog/g/gM-11753/
#
######################################################################

if [ ! -n "${DISPLAY_ADDR}" ]; then
    DISPLAY_ADDR=0x3e
fi
if [ ! -n "${SLEEP_TIME}" ]; then
    SLEEP_TIME=10
fi

while $(sleep ${SLEEP_TIME}); do
    [ $(i2cdetect -y 1 |grep $(echo ${DISPLAY_ADDR} | sed 's/^0x//') |wc -l) -ne '1' ] && continue

    IPS=$(LANG=en_AU ifconfig |grep -w inet |grep -v 127.0.0.1 |awk -F' ' '{print $2}')

    for i in ${IPS}; do
        firstcol=$(echo -n ${i} |cut -c -8 |od -An -tx1 |sed -s 's/ / 0x/g')
        secondcol=$(echo -n ${i} |cut -c 9- |od -An -tx1 |sed -s 's/ 0a//g' |sed -s 's/ / 0x/g')

        i2cset -y 1 ${DISPLAY_ADDR} 0 0x38 0x39 0x14 0x70 0x56 0x6c i
        i2cset -y 1 ${DISPLAY_ADDR} 0 0x38 0x0d 0x01 i
        i2cset -y 1 ${DISPLAY_ADDR} 0x40 ${firstcol} i
        i2cset -y 1 ${DISPLAY_ADDR} 0x00 0xc0 i
        i2cset -y 1 ${DISPLAY_ADDR} 0x40 ${secondcol} i

        sleep ${SLEEP_TIME}
    done
done
exit 0
