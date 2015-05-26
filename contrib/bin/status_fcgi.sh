#!/bin/bash

dir=$HOME/app/DynIP
. $dir/etc/fcgi.env

pid=`cat $pidfile 2>/dev/null`
test -z "$pid" && {
    echo "fastcgi not running for app $appname"
    exit 0
}

ps $pid >/dev/null 2>&1 && {
    echo "fastcgi running for app $appname with PID $pid"
    exit 0
}

echo "fastcgi not running, stale PID $pid in $pidfile"
exit 0
