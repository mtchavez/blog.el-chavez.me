---
categories:
- serverless
- lambda
- til
- aws
keywords:
- serverless events with existing s3 bucket
- serverless s3 events
- serverless lambda s3 events with existing bucket
- serverless s3 existing bucket
- til
tags:
- til
- serverless
- lambda
- aws
series:
- til
- serverless
- aws
comments: true
date: '2019-08-12'
title: Serverless Events with Existing S3 Bucket
description: Serverless AWS S3 events with an existing bucket. When you have a bucket already and can't delete the contents you still have an option with serverless to re-use that bucket.
url: /2019/08/12/serverless-events-existing-s3-bucket
featured_image: images/featured/server.jpg
images:
- images/featured/server.jpg
---
[Serverless](https://serverless.com) helps you with [functions as a service](https://en.wikipedia.org/wiki/Function_as_a_service) across multiple providers.
Using serverless with [AWS](https://aws.amazon.com) allows you to tie these functions
into your AWS infrastructure, or tie it into existing resources. Previously you
couldn't use existing S3 buckets for serverless lambda events. Today I learned that
you can now use existing buckets.
<!--more-->

Serverless offers a lot of [AWS Lambda events][aws-sls-events] to hook into for
triggering your lambda when some action occurs across your infrastructure or resources.
One of those resources is S3 for events like when an object is created. Previously serverless did not have a way of handling these events when the S3
bucket already existed.

Per the Serverless documentation, the option to allow existing buckets is only
available as of `v.1.47.0` and greater. You can see the [example in the docs][sls-existing-buckets] to read up on the other important notes provided. The
way to configure your serverless functions to allow existing S3 buckets is simple
and requires you to only set `existing: true` on your S3 event as so:

```yaml
functions:
  s3ObjectCreated:
    handler: objectCreated
    events:
      - s3:
          bucket: existing-bucket-name
          event: s3:ObjectCreated:*
          existing: true
```

It's as simple as that. There are some limitations that they call out [in the documentation][sls-existing-buckets]. But for most, this will likely work for your usecase.

[aws-sls-events]: https://serverless.com/framework/docs/providers/aws/events/
[serverless]: https://serverless.com
[sls-existing-buckets]: https://serverless.com/framework/docs/providers/aws/events/s3#using-existing-buckets
