#/bin/bash

. .env

AWS_ACCOUNT_ALIAS=account_one
GITLAB_RUNNER_TAG=$AWS_ACCOUNT_ALIAS-runner
CLUSTER_NAME=main
STAGE=dev

curl -X POST \
     -F token=$GITLAB_PIPELINE_TRIGGER_TOKEN \
     -F ref="release" \
     -F "variables[AWS_ACCOUNT_ALIAS]=$AWS_ACCOUNT_ALIAS" \
     -F "variables[GITLAB_RUNNER_TAG]=$GITLAB_RUNNER_TAG" \
     -F "variables[CLUSTER_NAME]=$CLUSTER_NAME" \
     -F "variables[STAGE]=$STAGE" \
     https://gitlab.service.nsw.gov.au/api/v4/projects/231/trigger/pipeline