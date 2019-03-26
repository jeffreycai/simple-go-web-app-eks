## Functions

FUN_BASEDIR=$(dirname $(readlink -f "$0"))

## Log
log() {
    local msg=$1
    echo "- ${msg}"
}

header() {
    local msg=$1
    echo -e "--------------"
    echo -e $msg
    echo -e "--------------"
}

## kubernetes initialization
k8s_init() {
    local cluster_name=$1
    local aws_auth_cm_file_path=$2

    aws eks update-kubeconfig --name ${cluster_name}
    kubectl apply -f ${aws_auth_cm_file_path}
}

# convert an account number to account alias by checking conf array
aws_account_number_to_alias() {
    local account_number=$1
    . $FUN_BASEDIR/config.sh

    # loop all accounts, try to find a matched alias
    for acc_alias in ${!AWS_ACCOUNTS[@]}; do
        if [ ${AWS_ACCOUNTS[$acc_alias]} == $account_number ]; then
            # if found, echo the alias as function output
            echo $acc_alias
        fi
    done
}

# check if the is_my_turn stage output file is present
is_it_my_turn() {
    if [ ! -z "$CI" ] && [ ! -f $FUN_BASEDIR/../stage_output.is_my_turn-${CI_RUNNER_TAGS} ]; then
        # header "stage_output.is_my_turn-${CI_RUNNER_TAGS} artifact NOT present. It is not my turn so I quit. Nothing to do"
        echo "no"
    elif [ ! -z "$CI" ]; then
        # header "stage_output.is_my_turn-${CI_RUNNER_TAGS} artifact IS present. It is my turn. Continue.."
        echo "yes"
    else
        # header "You are running under local instead of Gitlab CI. No need to check. Continue.."
        echo "yes"
    fi
}