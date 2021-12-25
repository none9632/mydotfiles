#!/bin/sh

if [ $(stat --printf="%s" $1) -eq 0 ]
then
    echo "" > $1
else
    sed -i "1s|^|\n|" $1
fi
