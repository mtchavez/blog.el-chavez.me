---
categories:
- terraform
- ci-cd
- devops
- infrastructure as code
keywords:
- terraform
- terraform ci/cd
- devops
- infrastructure as code
tags:
- terraform
- ci-cd
- devops
- infrastructure as code
comments: true
date: '2019-07-29'
title: Terraform CI/CD
description: A CI/CD Approach To Terraform
url: /2019/07/29/terraform-ci-cd-approach
featured_image: images/featured/continuous.jpg
---
[Terraform][terraform] helps in creating cross-cloud immutable infrastructure with code.
As with most code there is an ideal of having your codebase automated with tests and deploys.
How can this work with terraform? Does it work in a sensible way to give you confidence in
your changes and how they ultimately get applied? Trying to answer these questions led to
the following approach that I've used to attempt to try having a CI/CD solution for a
terrorm codebase.
<!--more-->
## Setup

- Installing terraform can be found in the [Terraform install guide][terraform-install]
- An AWS account (can be replaced with other providers)
- Some prior knowledge or use of Terraform is helpful since everything won't be covered

## Initializing

Terraform is built with the notion of modules that define your resources. Each directory is
a module to Terraform. Start out by creating a directory for your Terraform module

```bash
mkdir terraform-ci
cd terraform-ci
git init
```

Next define some resources and the AWS provider in the `main.tf` file of our module.

```hcl
provider "aws" {
  profile    = "default"
  region     = "us-east-1"
}

resource "aws_instance" "test-instance" {
  ami           = "ami-2757f631"
  instance_type = "t2.micro"
}
```

Now you can run `terraform init` which will set up the state and providers for the module
we will be working with.

## Workspaces

[Workspaces][terraform-workspace] are a concept in Terraform that help you manage state across multiple namespaces.
The namespaces could be a way to separate your state by `production` and `staging` and `qa`
for example. Since each directory is a module in Terraform the state for your production and
staging infrastructure can't use the same state. Rather than making a module per stage and duplicating
all your resources per module directory you can use workspaces to manage things more cleanly.

There is a `default` workspace that is used without needing to do anything. In this approach we want
a staging and production workspace. To do that we can use the CLI to create them

```bash
# Create staging workspace
terraform workspace new staging

# Create production workspace
terraform workspace new production
```

Once they are created you can view all the workspaces with `terraform workspace list`. Last step is
to select the workspace you want to be working with you have to explicitly do so with the CLI:

```bash
# Selecting the staging workspace
terraform workspace select staging
```

Splitting up our state by staging and production is useful for getting parity across environments.
It is also a pattern we will want to mimic with our git branches and development flow to make the
process match more semantically.

## Git Setup

By default when you use git for version control the default branch is the `master` branch.
Similar to the Terraform workspaces, we want to create a non-default flow and have branches for
`staging` and `production`.

```bash
git co -b staging
git push -u origin staging

git co -b production
git push -u origin production
```

If you use [Github][github] you can [change your default branch][default-branch] to be that
of the _staging_ branch. This will be where we work on all the features and new development
that gets deployed and tested against first. This is to ensure that the _production_
code and branch are always in a known and well vetted state. When you branch it will
be from the _staging_ branch and when you want to merge new changes in it will be into
the _staging_ branch rather than the default _master_ branch.

## Continuous Integration (CI)

A continuous integration approach for Terraform could entail a handful of different things.
On one hand you could go a fully integrated route and use tools like [Terratest][terratest]
to spin up all your defined resources. While this offers you a lot of confidence in your
Terraform infrastructure being applied as you expect, you may find this a cost prohibitive
approach. A more streamlined way to achieve some confidence in what ends up being applied
is to leverage these workspaces to test them in your _non-production_ environments first.

Terraform has two main actions that you will want to ensure run cleanly and those are
**plan** and **apply**. The _plan_ step goes through your defined resources and builds
up the state of everything to ensure it can attempt to executed. _Apply_ does just that,
it will apply the known state at the point it is ran. For our CI approach we want to
be able to verify these will run.

If you use a CI provider like CircleCI, or similar, you can set up the integration to run
your CI pipeline when you open a pull request for new changes into our _staging_ branch.
The main concerns of the pipeline will be to _validate_ the terraform files, _plan_
the terraform state out, and _apply_ that state. An example workflow for that might look
like so:

```yaml
base_image: &base_image
              hashicorp/terraform:latest

working_directory: &working_directory
                     ~/terraform

default_config: &default_config
  docker:
  - image: *base_image
  working_directory: *working_directory

terraform_init: &terraform_init
  run:
    name: initialize
    command: terraform init

set_terraform_workspace: &set_terraform_workspace
  run:
    name: set terraform environment
    command: |
      if [ "${CIRCLE_BRANCH}" == "production" ]; then
        terraform workspace select production
      else
        terraform workspace select staging
      fi

version: 2.1

#
# CI Jobs
#
jobs:
  build:
    <<: *default_config
    steps:
    - checkout
    - *terraform_init
    - *set_terraform_workspace
    - persist_to_workspace:
        root: *working_directory
        paths:
        - .terraform

  verify:
    <<: *default_config
    steps:
    - checkout
    - attach_workspace:
        at: *working_directory
    - attach_workspace:
        at: ~/
    - run:
        name: verify
        command: terraform verify

  plan:
    <<: *default_config
    steps:
    - checkout
    - attach_workspace:
        at: *working_directory
    - attach_workspace:
        at: ~/
    - run:
        name: plan
        command: terraform plan -out=terraform.plan
    - persist_to_workspace:
        root: *working_directory
        paths:
        - terraform.plan

  apply:
    <<: *default_config
    steps:
    - checkout
    - attach_workspace:
        at: *working_directory
    - attach_workspace:
        at: ~/
    - run:
        name: apply
        command: terraform apply -auto-approve terraform.plan

#
# CI Workflows
#
workflows:
  version: 2
  update_infrastructure:
    jobs:
      - build:
      - verify:
          requires:
            - build
      - plan:
          requires:
            - verify
            - build
      - apply:
          requires:
            - plan
          filters:
            branches:
              only:
                - staging
                - production
```

This is a lot to un-pack but lets go over it with the continuous delivery part of
the CI pipeline.

## Continuous Delivery (CD)

In the previous _CI_ section there is an example CI workflow that walks through
a lot of things. First it is using the [Hashicorp Terraform Docker image][terrform-image]
to execute all the commands and jobs in. The first job is called _build_ and this
job is making sure that the `terraform init` command can run without issue and
it saves the `.terraform` directory to be used with subsequent jobs so that the
terraform state and providers is all set up to run commands.

Once Terraform is initialized we make sure the `verify` command runs successfully.
Each of the jobs will need to make sure the correct workspace is selected. If you
look at the `*set_terraform_workspace` anchor in YAML you can see that for any
non-production branch you run through CI it will be running against the `staging`
workspace. From the `production` branch it will apply everything against your
production infrastructure.

After verify is successfull we finally run our `terraform plan` command. One thing
of note here is we are utilizing the `-out` flag to print out our plan at the time
it is ran. This allows us to knowingly plan the changes that are at the current
point of the code and time the plan command was ran. This plan will be saved in the
CI workflow to be used by the next job, apply.

The last job to be ran will require that we have a valid plan generated so that we
can run `apply` against that plan. The plan generated from the `plan` job is used
as an argument to `terraform apply`. One other thing here is that we are passing
the `-auto-approve` flag so that there is no prompt in CI to say _yes_ to applying
the changes.

## Feature Branches

If you are running feature branches and creating pull requests to merge into
the mainline branch, _staging_ in this case, then you will want to make sure
that the `apply` job doesn't run in CI. To avoid multiple changesets in feature
branches wiping out the state on competing branches it makes sense to verify
the `plan` step runs and the code can be initialized and is verified. CircleCI
uses _filters_ to achieve that on the workflow jobs.

## Production

Once you have run applied your changes against staging, verified they work as
expected, then you can start the process to deploy your changes out to production.
For those who want to use pull requests in [Github][github] you can make a new
pull request from your _staging_ branch into your _production_ branch. This
will trigger a new CI build that will run all the previously explained jobs
but with the _production_ workspace selected.

The plan output will show all the new changes to apply in your _production_ infrastructure
and if your CI pipeline passes then it has gone out and been applied.

## Caveats

Some things to look out for:

1. Using providers like AWS will need credentials in your CI pipeline and terraform vars
1. State should be saved remotely ([See docs][remote-state]). Which means your terraform version
   in CI will need to be consistent. If it changes because someone ran it locally with a different
   version it will have conflicts.
1. Resources need to be named with the `workspace` in mind to avoid naming conflicts
  * e.g `name = "my-${terraform.workspace}-ec2-instance"`
1. Permissions for your providers, like AWS, will likely need to have full access which
   can be a security concern to run from CI instances you don't have full control over.
1. Terraform can apply things and fail and leave your infrastructure in a half applied state.
1. Extra branches for each environment/stage can be cumbersome at times.

## Conclusion

Overall I've been running something very similar the last year or so to achieve
a CI/CD approach with Terraform. It has some drawbacks but all in all it has helped
give some clarity to what state our Terraform workspaces are in. Also, we have
been able to iterate as a team with deployments happening continuously for staging
while holding extra care and caution before things get to production.

---

### Extra Credit

- Use [Terratest][terratest] with multiple test accounts hooked up to provision cleanly from CI
- If using AWS, or other providers that allow MFA, hook up MFA to be required for your permissions
  * Will require extra CI steps
- Add a manual approval step in CI to ensure someone looks at the plan that is generated before it applies
  * Can be easy to forget CI jobs are waiting
- Build your own CI docker image to use with all the extra tooling you need

[default-branch]: https://help.github.com/en/articles/setting-the-default-branch
[github]: https://github.com
[terraform]: https://www.terraform.io
[terraform-image]: https://hub.docker.com/r/hashicorp/terraform
[terraform-install]: https://learn.hashicorp.com/terraform/getting-started/install.html
[terraform-workspace]: https://www.terraform.io/docs/state/workspaces.html
[terratest]: https://github.com/gruntwork-io/terratest
