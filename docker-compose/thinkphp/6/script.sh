#!/bin/sh

FILENAME="./${NAME}.yaml"

if [ -f $FILENAME ] && [ -f "$(which docker-compose)" ]
then
    docker-compose -f $FILENAME pull && docker-compose -f $FILENAME -p thinkphp-$NAME up -d
fi
