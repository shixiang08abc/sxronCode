#!/usr/bin/sh

cat $1 | perl encoder.pl | sh crawler.sh $2
