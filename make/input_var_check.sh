#/bin/bash

required_variables=("AWS_ACCOUNT_ALIAS" "CLUSTER_NAME" "STAGE")

BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

## include functions
. ${BASEDIR}/functions.sh

## check all required vars
for var_name in ${required_variables[*]}; do
  var_value=$(env | grep "$var_name=" | cut -d '=' -f 2)
  if [ -z $AWS_ACCOUNT_ALIAS ]; then
    header "Please provide env var '$var_name'"
    exit 1
  fi
done

header "You've provided the required env vars. You are good to go. Continue .."
