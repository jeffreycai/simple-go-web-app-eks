#!/bin/bash
BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

## include functions
. ${BASEDIR}/functions.sh
. ${BASEDIR}/config.sh
. ${BASEDIR}/../.env

# store AWS_ACCOUNT_ID to file, to be used later
echo "${AWS_ACCOUNTS["$AWS_ACCOUNT_ALIAS"]}" > $BASEDIR/../stage_output.aws_account_id

# store AWS_ACCOUNT_ALIAS to file, to be used later
aws_account_number_to_alias ${AWS_ACCOUNTS["$AWS_ACCOUNT_ALIAS"]}
#echo "${AWS_ACCOUNTS["$AWS_ACCOUNT_ALIAS"]}" > $BASEDIR/../stage_output.aws_account_id

# store AWS_ROLE_TO_ASSUME to file, to be used later
echo "arn:aws:iam::${AWS_ACCOUNTS["$AWS_ACCOUNT_ALIAS"]}:role/${AWS_ASSUMED_ROLE_NAME}" > $BASEDIR/../stage_output.aws_role_to_assume