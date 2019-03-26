#/bin/bash
##
# This script is only called when we are running under gitlab ci
# it takes one input option from cmd, the value is either "init" for initialization or "check" for checking
# "init": generate a stage output file if the gitlab job is against the current aws account
# "check": check if the stage output file is present
##

BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

## include functions and confs
. ${BASEDIR}/functions.sh

## are we initializing the stage output file or just checking
ACTION=$1

# "init": generate a stage output file if the gitlab job is against the current aws account
if [ "$ACTION" == "init" ]; then
  # set default var of GITLAB_RUNNER_TAG if not exist
  if [ -z ${GITLAB_RUNNER_TAG} ]; then
    GITLAB_RUNNER_TAG=${AWS_ACCOUNT_ALIAS}-runner
  fi

  # check if the current runner is the one to execute the job. if not, no need to do anything. exit
  if [ "${GITLAB_RUNNER_TAG}" != "${CI_RUNNER_TAGS}" ]; then
    header "This job is to run under account ${AWS_ACCOUNT_ALIAS}. Nothing to do with me."
    exit 1
  fi

  # if all pass (it's my turn), we make an artifact output file, which the next stage depends on to verify if need to proceed
  header "This job is to run under account ${AWS_ACCOUNT_ALIAS}. Yeah, it's me!"
  echo "it's my turn" > stage_output.is_my_turn-${CI_RUNNER_TAGS}

# "check": check if the stage output file is present
elif [ "$ACTION" == "check" ]; then
  if [ $(is_it_my_turn) == "no" ]; then
    header "stage_output.is_my_turn-${CI_RUNNER_TAGS} artifact NOT present. It is not my turn so I quit. Nothing to do"
  else
    header "It is my turn. Continue.."
  fi
fi
