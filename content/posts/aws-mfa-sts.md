---
categories:
- developer tools
- aws
- security
- aws cli tools
keywords:
- developer tools
- aws
- security
- aws cli tools
tags:
- developer tools
- aws
- security
- aws cli tools
series:
- aws
- security
- developer tools
comments: true
date: '2018-05-02'
title: AWS with STS for MFA Required Access
description: Programatic AWS access using STS when MFA is required.
url: /2018/05/02/aws-mfa-sts
---
If you are using AWS for anything, and security is on top of your mind, you may
have run into some friction using the AWS services programatically. May companies
require MFA to be set up just to access the AWS console. Some go even further by
adding the constraint of requiring a group, or all users, to use MFA for programatic
access to their account. If you have ever been put into this situation and tried
to use the AWS APIs you know how it can become a burden to now do the things you
are used to doing from simple CLI calls.
<!--more-->

## Security Reasons

With the current technical landscape people are becoming more aware of security
concerns and how that affects them day to day. The general public could be at
the other end of your own company's security gaffe. There is no wonder why any
company using AWS would want to turn on features that help even more with security.

As the developer who needs to now provide more information to run a simple command
it can be disruptive and time consuming. Luckily there are solutions, both provided
by AWS and otherwise, to make things more usable while providing the same security.

## Temporary Users

Some may find themselves creating temporary users with programatic access that
are not a part of the group who is required to provide MFA details to access
the AWS API. This can be a working approach, if you remember to clean up after
yourself and delete these temporary users.

You will also need to be disciplined to not give your temporary API users admin
access. The easy approach is to just give the user access to it all since you
know it is temporary. The problem here is you might run into issues with human
error forgetting to delete the user, exposing those credentials unknowingly, or
ending up using the _temprorary user_ in a more long term way. This is why AWS
has a service called [Simple Token Service][sts] that solves some of these issues.

## STS With MFA

STS simply helps you create temporary credentials that you can then use to access
services in your AWS account. This can be useful when working with contractors,
other non-technical departments, or even the technical users themselves. You
can use your MFA device attached to users who are required to provide those
credentials for programatic access and the credentials are temporary up to a max
time of 24 hours.

## CLI via a Go Package

To simplify the usage of using these secure approaches to accessing the AWS APIs
I ended up making a CLI in [Go][golang] that wraps STS and uses the [AWS CLI][aws-cli]
configuration to allow you to easily use your temporary credentials.

The package is called [aws-mfa-sts][aws-mfa-sts] and can be installed from the
[github releases][aws-mfa-sts-releases] page for the repository or from a
`go get -u -v github.com/mtchavez/aws-mfa-sts`, if you have [Go][golang] already
set up. The command is simple where you generate a token for a device that is
tied to your IAM user. The [AWS CLI][aws-cli] is configured with a new profile
that is `default-sts` which you can then set as the default profile in your
environment or pass the `--profile` flag along to the CLI.

I've been using this approach a few months and have found these steps to be
easy enough to use. Typically I generate a token that will last me the work day
and not have to think about it until the next day or time I need to use the API.
Since the tokens time out I don't have to think twice about leaving my admin
priveledges open. On top of that, I get to use the [AWS CLI][aws-cli] or export
the credentials to the environment and use the AWS packages from various languages
without needing to do setup each time per language.

[aws-cli]: https://aws.amazon.com/cli/
[aws-mfa-sts]: https://github.com/mtchavez/aws-mfa-sts
[aws-mfa-sts-releases]: https://github.com/mtchavez/aws-mfa-sts/releases
[golang]: https://golang.org
[sts]: https://docs.aws.amazon.com/STS/latest/APIReference/Welcome.html
