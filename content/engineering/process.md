---
categories:
- engineering processes
- best practices
- xp
- agile
- interviews
keywords:
- mtchavez
- engineering processes
- best practices
- xp
- agile
- interviews
draft: true
date: '2017-03-01'
title: Engineering Processes
description: A high-level list to review on process and best practices
---

## Can you describe or walk through a typical engineering week?

- What processes do you all use?
- How are things prioritized?
- Is your work given any sort of estimation of difficulty or time to complete?

## When projects come up across two or more teams how are things coordinated and planned out?

- Is there up-front discussion or planning out of system touch points?
- How is blocking work handled or mitigated when relying on the work of other teams?

## What is your approach for more unknown or exploratory tasks?

- Are there success metrics defined up front and monitored via whatever metrics exported?
- Do you do small rollouts to gather further insight or metrics?
- Are engineers empowered to have exploratory or research tasks?

## How are things getting decided to be worked on?

- When and where are things planned out?
- Is it ahead of time from the business or is there engineering input?
- Are things prioritized and, if so, how are they?
- Do roadmaps get made out of the work required to complete features or from the timing of business needs?
- Is there any kind of A/B testing approach to get minimum features out to decide on what makes the most sense to build?

## What is your testing approach and culture?

- Do you do acceptance testing?
- Is there more of a focus on integration or unit testing?
- Do you have continuous integration?
- Do you monitor test coverage for projects?
- What is your approach to testing services or cross system integrations?
- How long does your longest test suite run?
- Do you only deploy when green?
- Do you have continuous delivery?
- Do you fail builds for linters and code styling conventions?

## What is your VCS flow, do you use git or something else? (assuming git for questions)

- What is your typical feature/bug flow with git?
- Do you have any strong feelings on rebasing vs merging?
- Are pull requests opened during development or only when ready to review/merge?
- Are reviews required on pull requests or code to be deployed/merged?
- Are there coding conventions defined, i.e. linters, to ensure comments are not all styling based?

## Are engineers mostly working alone on features or projects?

- Do engineers there ever pair program?
- Are engineers handed a project to complete by themselves or are they mostly on a team?
- Are there project leads or is there any kind of structure/hierarchy to the engineering team?

## Deployment and Infrastructure

- How do deploys typically look?
- If new services are being made how does infrastructure get planned and rolled out?
- What is the process for rolling back bad deploys?
- How long do deploys take typically?
- Is there a DevOps or Infrastructure team in place?
- Are there any infrastructure as code tools in place?
- Is DevOps, or similar, owned by the whole engineering team or just a DevOps team?

## After releasing features is there any engineering process or follow up?

- Are there metrics in place and dashboards or info radiators to go review affects of changes?
- What is your typical post deploy process if any?
- Are things rolled out to a percentage of users first before going to everyone or just all at once?
- Is there a staging or beta environment to have things reviewed before live deploys?
- If there is staging or beta is there production parity with data and metrics monitoring?
- When things have issues or bugs do you do rollbacks?

## What are some of the tools you use during development?

- What do you use to keep environment parity across dev/staging/beta/prod etc?
- Are these tools and processes owned by the whole engineering team to keep up with, manage, and use?

## What alerts/alarms/bells do you have to let you know what’s failing?

- What services or systems do you have set up to handle this?
- Is all of engineering on an on-call rotation for this?
- Is pagerduty, pingdom, or whatever else set up to handle these things?
- How are outages or errors handled? What is a typical plan of attack? Is it all hands on deck or what?
