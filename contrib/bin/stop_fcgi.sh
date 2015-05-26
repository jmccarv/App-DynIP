#!/bin/bash

dir=$HOME/app/DynIP
. $dir/etc/fcgi.env

pid=`cat $pidfile`
test -z "$pid" && {
    echo "No PID to kill, is fastcgi running?"
    exit 1
}

kill $pid
#pkill -f "perl-fcgi-pm \[$appname]"
