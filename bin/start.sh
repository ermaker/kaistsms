#!/bin/bash
(cd $(dirname $0)/..; /usr/local/rvm/bin/ruby-1.9.3-p0@kaistsms -Ilib bin/webserver 7001 </dev/null &>>log/access.log &)
