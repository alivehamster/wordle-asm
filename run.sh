#!/bin/sh

name=main

if [ -n "$1" ]; then
 	name=$1
fi

gcc -nostdlib "$name.s" functions.s output.s -o binary

ERROR_CODE=$?

if [ $ERROR_CODE -ne 0 ]; then
    echo "The build failed with error code: $ERROR_CODE"
    exit $ERROR_CODE
fi

./binary