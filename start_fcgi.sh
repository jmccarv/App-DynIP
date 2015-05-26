#!/bin/bash

dir=$HOME/app/DynIP
nohup $dir/app/script/dynip_fastcgi.pl -l 127.0.0.1:9001 -n 2 > $dir/log/fastcgi.log 2>&1 &
