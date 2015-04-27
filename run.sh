#!/bin/bash

db_path=/data/db
lockfile=$db_path/mongod.lock
repl_set=$REPL_SET

if [ -f $lockfile ]; then
    rm $lockfile
    mongod --dbpath ${db_path} --repair
fi

if [ ! -f $db_path/.mongodb_password_set ]; then
    /set_mongodb_password.sh
fi

cmd='mongod --nojournal --httpinterface --rest --replSet '$repl_set 
if [ "$AUTH" == "yes" ]; then
    cmd="$cmd --auth"
fi

if [ ! -f $lockfile ]; then
    exec $cmd
else
    cmd="$cmd --dbpath $db_path"
    rm $lockfile
    mongod --dbpath $db_path --replSet $repl_set --repair  && exec $cmd
fi

