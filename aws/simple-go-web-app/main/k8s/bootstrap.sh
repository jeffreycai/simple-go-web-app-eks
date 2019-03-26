#!/bin/bash
BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

## include functions and confs
. ${BASEDIR}/../../../../make/functions.sh

cd $BASEDIR


header "K8s bootstrapping"

## aws authentication mapping to k8s
# dockerize the conf file template first
log "dockerize aws-auth-cm.yml .."
dockerize -delims "<%:%>" -template aws-auth-cm.yml.tmpl:aws-auth-cm.yml

# update kubeconfig
log "updating local kubeconfig file .."
aws eks update-kubeconfig --name $CLUSTER_FULL_NAME

# apply aws-auth-cm.yml
log "applying aws-auth-cm.yml .."
kubectl apply -f aws-auth-cm.yml

# check if worker nodes are ready
log "checking if all workder nodes are READY .."
# loop till we find nodes are ready
for i in {1..30}; do
  ALL_READY=1
  OUTPUT=$(kubectl get nodes | awk '{print $2}')
  for token in $OUTPUT; do
    # as long as there is one NotReady, we mark the flag
    if [ $token == "NotReady" ]; then
      ALL_READY=0
    fi
  done
  if [ ! -z $ALL_READY ]; then
    # if all ready, break and continue, otherwise, keep checking
    break
  fi
  sleep 5
done

if [ -z $ALL_READY ]; then
  header "Error: Timeout when waiting for the worker nodes to be ready."
  exit 1
else
  log "all worker nodes are ready."
fi

