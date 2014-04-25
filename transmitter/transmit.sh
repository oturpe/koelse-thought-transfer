#!/bin/bash

tempDir=tmp
tempFile="$tempDir"/ajatus.ajatus
targetFile="oturpe@koti.kapsi.fi:public_html/ajatustenluku/ajatus.ajatus"
length=10

if [ ! -d "$tempDir" ]; then
    mkdir "$tempDir"
fi

while [ true ]; do
	echo "Recording thought of length $length"
    python read_mind.py $length > "$tempFile"
    scp "$tempFile" "$targetFile"
    lengthSeed=`od -j 3567 -N 1 -t u1 -A n "$tempFile"`
    length=`expr $lengthSeed \/ 3 + 1`
done
