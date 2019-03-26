#!/bin/bash

BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

## include functions
. ${BASEDIR}/functions.sh

## sanitize a string to use only letters, numbers and -
sanitize() {
    local str
    str=$1

    echo $str | sed -r 's/[^0-9a-zA-Z]/\-/g'
}


## set the pipeline runner's username in .env file, to be used by pipeline job
if [ ! -z $CI ]; then
    # use GITLAB_USER_NAME, if running under Gitlab CI
    WHOAMI=$(sanitize $GITLAB_USER_NAME)
else
    # use `whoami` if running under workspace
    WHOAMI=$(sanitize $(whoami))
fi

## set WHOAMI in .env file, so it's exposed to following make jobs
whoami_exists=$(cat $BASEDIR/../.env | grep WHOAMI=)
if [ -z $whoami_exists ]; then
    echo "" >> $BASEDIR/../.env
    echo "WHOAMI=$WHOAMI" >> $BASEDIR/../.env
fi