#!/bin/bash
BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

## include functions and confs
. ${BASEDIR}/functions.sh
. $BASEDIR/../aws/$AWS_ACCOUNT_ALIAS/$CLUSTER_NAME/conf.env.vars

cd $BASEDIR

# quit if not my turn
if [ "$(is_it_my_turn)" == "no" ]; then
  header "Not my turn. Quit"
  exit 0
fi

# as node aws sdk uses AWS_REGION as the env var for region, we populate it with AWS_DEFAULT_REGION
if [ -z $AWS_DEFAULT_REGION ]; then
  export AWS_DEFAULT_REGION="ap-southeast-2"
fi
export AWS_REGION=${AWS_DEFAULT_REGION}

## eks cluster provision
header "Creating EKS cluster .."
# dockerzie the cluster cim template files
log "dockerize eks cluster cim template .."
dockerize -template $BASEDIR/../aws/$AWS_ACCOUNT_ALIAS/$CLUSTER_NAME/cloudformation/eks_cluster/_cim.yml.tmpl:$BASEDIR/../aws/$AWS_ACCOUNT_ALIAS/$CLUSTER_NAME/cloudformation/eks_cluster/_cim.yml

# cim stack-up
log "cim stack-up .."
cim stack-up $BASEDIR/../aws/$AWS_ACCOUNT_ALIAS/$CLUSTER_NAME/cloudformation/eks_cluster --stage=${STAGE}
CFN_DETAILS=$(aws cloudformation describe-stacks --stack-name $AWS_ACCOUNT_ALIAS-gitlabci-eks-$CLUSTER_NAME-cluster-$STAGE)

export CLUSTER_ARN=$(echo $CFN_DETAILS | jq -r '.Stacks[0].Outputs | map(select(.OutputKey == "ClusterArn")) | .[].OutputValue')
export CLUSTER_CTL_SG=$(echo $CFN_DETAILS | jq -r '.Stacks[0].Outputs | map(select(.OutputKey == "ClusterControlPlaneSecurityGroup")) | .[].OutputValue')
export CLUSTER_END_POINT=$(echo $CFN_DETAILS | jq -r '.Stacks[0].Outputs | map(select(.OutputKey == "ClusterEndpoint")) | .[].OutputValue')


## eks node group provision
header "Creating EKS nodegroup .."
# dockerize the node group cim template files
log "dockerize eks node group cim template .."
dockerize -template $BASEDIR/../aws/$AWS_ACCOUNT_ALIAS/$CLUSTER_NAME/cloudformation/eks_nodegroup/_cim.yml.tmpl:$BASEDIR/../aws/$AWS_ACCOUNT_ALIAS/$CLUSTER_NAME/cloudformation/eks_nodegroup/_cim.yml

# cim stack-up
log "cim stack-up .."
cim stack-up $BASEDIR/../aws/$AWS_ACCOUNT_ALIAS/$CLUSTER_NAME/cloudformation/eks_nodegroup --stage=${STAGE}
CFN_DETAILS=$(aws cloudformation describe-stacks --stack-name $AWS_ACCOUNT_ALIAS-gitlabci-eks-$CLUSTER_NAME-nodegroup-$STAGE)

export CLUSTER_NODE_INSTANCE_ROLE=$(echo $CFN_DETAILS | jq -r '.Stacks[0].Outputs | map(select(.OutputKey == "NodeInstanceRole")) | .[].OutputValue')
export CLUSTER_NODE_SG=$(echo $CFN_DETAILS | jq -r '.Stacks[0].Outputs | map(select(.OutputKey == "NodeSecurityGroup")) | .[].OutputValue')


## eks additional resources provision
header "Creating EKS additional resources .."
# dockerize the additional resource cim template files
log "dockerize eks additional cim template .."
dockerize -template $BASEDIR/../aws/$AWS_ACCOUNT_ALIAS/$CLUSTER_NAME/cloudformation/eks_additional/_cim.yml.tmpl:$BASEDIR/../aws/$AWS_ACCOUNT_ALIAS/$CLUSTER_NAME/cloudformation/eks_additional/_cim.yml

# cim stack-up
log "cim stack-up .."
cim stack-up $BASEDIR/../aws/$AWS_ACCOUNT_ALIAS/$CLUSTER_NAME/cloudformation/eks_additional --stage=${STAGE}
CFN_DETAILS=$(aws cloudformation describe-stacks --stack-name $AWS_ACCOUNT_ALIAS-gitlabci-eks-$CLUSTER_NAME-cluster-$STAGE-additional)

export K8S_ADMIN_ROLE_ARN=$(echo $CFN_DETAILS | jq -r '.Stacks[0].Outputs | map(select(.OutputKey == "K8sAdminRoleArn")) | .[].OutputValue')


# k8s bootstrap
. $BASEDIR/../aws/$AWS_ACCOUNT_ALIAS/$CLUSTER_NAME/k8s/bootstrap.sh
