#!/bin/bash
BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd $BASEDIR

## include functions and confs
. functions.sh
. $BASEDIR/../aws/$AWS_ACCOUNT_ALIAS/$CLUSTER_NAME/conf.env.vars

# as node aws sdk uses AWS_REGION as the env var for region, we populate it with AWS_DEFAULT_REGION
export AWS_REGION=${AWS_DEFAULT_REGION}

# update kubeconfig
log "updating local kubeconfig file .."
aws eks update-kubeconfig --name $CLUSTER_FULL_NAME
