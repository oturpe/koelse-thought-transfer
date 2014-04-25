#!/bin/bash

sourceFile=koti.kapsi.fi/oturpe/ajatustenluku/ajatus.ajatus
tempFile=ajatus.ajatus
rateSeed=0
oldSeed=0

while [ true ]; do
    wget "$sourceFile" -O "$tempFile"
  	rateSeed=`od -j 5000 -N 1 -t u1 -A n "$tempFile"`
  	channelSeed=`od -j 2456 -N 1 -t u1 -A n "$tempFile"`
    if [ $rateSeed -ne $oldSeed ]; then
        oldSeed=$rateSeed
    	rate=`expr \( $rateSeed + 1 \)  \* 200`
    	channels=`expr $channelSeed \/ 128 + 1`
    	echo "Playing new thought at rate $rate on $channels channels"
        pacat --rate $rate --format u8 --channels $channels "$tempFile"
    else
    	echo "Skipping already received thought (rate seed $rateSeed)"
    fi

    sleep 2
done
