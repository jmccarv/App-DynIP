#!/bin/bash

dir=$HOME/app/DynIP
. $dir/etc/fcgi.env

cd $dir/app
nohup $dir/app/script/dynip_fastcgi.pl -l 127.0.0.1:9001 -d -p $pidfile -n 2 > $logfile 2>&1 &
