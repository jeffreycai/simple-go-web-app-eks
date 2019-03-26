# infra-aws-eks

Gitlab CICD to provision EKS cluster

## How to run this pipeline

You can choose to run in your workspace, or via Gitlab CI.

Name your EKS cluster (CLUSTER_NAME), e.g. "main". Lower case letters only.

Create your EKS cluster folder under `aws/<AWS_ACCOUNT_ALIAS>/<CLUSTER_NAME>`. Populate the folder accordingly (you can take an existing folder as an example)

Folder will look like:


```
aws/
└── simple-go-web-app
    └── <CLUSTER_NAME>
        ├── cloudformation
        │   ├── eks_cluster
        │   │   ├── _cim.yml.tmpl # cim conf file, dockerize template
        │   │   └── eks_cluster.template.yaml # cfn template for eks cluster
        │   ├── eks_nodegroup
        │   │   ├── _cim.yml.tmpl # cim conf file, dockerize template
        │   │   └── eks_nodegroup.template.yaml # cfn template for eks node group
        │   └── <other folders that you'll need for extra cfn templates>
        ├── conf.env.vars # main conf file for all confs with this eks cluster
        └── k8s
            ├── aws-auth-cm.yml.tmpl # aws iam mapping to k8s rbac
            ├── bootstrap.sh # k8s bootstraping script
            └── <other k8s conf files>
```

* cim conf files are populated with `dockerize`. env vars come from `conf.env.vars`
* k8s conf files are populated with `dockerize`. env vars come from `conf.env.vars`

### Run via Gitlab CI

1. Go to [Gitlab CI/CD > Pipelines](https://gitlab.service.nsw.gov.au/aws-platform/infra-aws-eks/pipelines). Click `Run Pipleline`
2. Choose `release` branch for `Create for` dropdown (pipeline is configured to run only on `release` branch)
3. Add the following vars for `Variables`
```
AWS_ACCOUNT_ALIAS # the aws account you want to run pipeline against
CLUSTER_NAME # the EKS cluster identifier, lower case letters only. e.g. "main"
STAGE # what env this cluster is for. "dev", "stage" or "prod". Final name of the cluster will be a combination for CLUSTER_NAME and STAGE

GITLAB_RUNNER_TAG # optional, this should be the gitlab runner's tag name. if not passed, it will by default be `${AWS_ACCOUNT_ALIAS}-runner`
```
4. Click `Create pipeline`

### Run on your own workspace 

1. Copy `.env.template` file as `.env`
2. Complete the `.env` file
```
AWS_DEFAULT_REGION=ap-southeast-2
AWS_SECRET_ACCESS_KEY # the aws cli credential used to assume AWS_ASSUMED_ROLE_NAME
AWS_ACCESS_KEY_ID # the aws cli credential used to assume AWS_ASSUMED_ROLE_NAME

AWS_ACCOUNT_ALIAS # the aws account alias, e.g. account_one
AWS_ASSUMED_ROLE_NAME # the role name to assume under AWS_ACCOUNT_ALIAS. e.g. PipelineRole
CLUSTER_NAME # the identifier of EKS cluster. lower case letters only. e.g. "main"
STAGE # dev / stage / prod. Final name of the cluster will be a combination for CLUSTER_NAME and STAGE
```
3. `make stack-up` to trigger the pipeline
4. `make shell` to start a shell debug session

## Gitlab CI

`.gitlab-ci.yml` defines details of gitlab ci stages:
- *Input_var_check*: checks all required env vars are provided
- *Is_it_my_turn*: this stage is for all gitlab runners to check if this pipeline run is against himself. `AWS_ACCOUNT_ALIAS` vars defines the account target.
- *Stack-up*: spins up EKS

# References

* cim: [https://github.com/thestackshack/cim](https://github.com/thestackshack/cim)
* dockerize: [https://github.com/jwilder/dockerize](https://github.com/jwilder/dockerize)