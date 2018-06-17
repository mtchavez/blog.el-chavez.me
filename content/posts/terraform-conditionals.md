---
categories:
- terraform
- devops
- infrastructure as code
keywords:
- terraform
- terraform conditionals
- terraform conditional resource
- conditionals in terraform
- devops
- infrastructure as code
tags:
- terraform
- devops
- infrastructure as code
comments: true
date: '2018-06-17'
title: Terraform Conditionals
description: Using conditionals in Terraform
url: /2018/06/17/terraform-conditionals
---
[Terraform][terraform] is a very versatile tool to help automate your infrastructure
and codify your infrastructure as code. With a large open source community and
tons of providers across multiple cloud platforms it allows developers to create
plans for spinning up infrastructure effortlessly. One thing I ran into that needed
a little more effort was adding conditional steps to a configuration plan. Due to
the complex nature of Terraform and how it attempts to plan out how it will execute
your configuration it is a little more involved to get conditionals working.
<!--more-->
## HCL

Terraform uses it's own custom language called [HCL][hcl] (HashiCorp Configuration Language).
The language allows simple instructions to be used when writing up your
terraform configuration. You can set variables and execute built in functions from dynamic
contexts. An example of defining a variable and using it would be:

```
variable "subnet" {
  description = "Subnet to use"
}

resource "aws_instance" "web" {
  subnet = "${var.subnet}"
}
```

The built in conditional syntax allows you to make that a bit more dynamic based
on the stage of your infrastructure:

```
resource "aws_instance" "web" {
  subnet = "${var.env == "production" ? var.prod_subnet : var.dev_subnet}"
}
```

Using these language features we are able to add conditional resources to our
Terraform configuration.

## Conditional Resources

The example I will use will be conditionally adding SSL certificates to resources.
This will reqoure conditional resources and some dynamic configuration for your
resources as well. First we want to create a variable that you want to use to
describe your conditional resource, such as `use_ssl`. The following sets up a
variable that defaults to `false` for when to use an SSL certificate or not.

```
variable "use_ssl" {
  description = "Set to true when using an SSL certificate on resources"
  value = false
}
```

Next for your resources that you want to conditionally be present for we have
to configure the `count` setting which exists for each resource. When you do
not want the resource you can set the count to `0`. With that knowledge you can
use your variable to conditionally set it to a count of zero or one.

```
resource "heroku_app" "serivce-app" {
  name = "org-serivce-app"
}

resource "heroku_addon" "ssl-addon" {
  app   = "${heroku_app.service-app.name}"
  count = "${var.use_ssl ? 1 : 0}"
  plan  = "ssl"
}

resource "heroku_cert" "ssl_certificate" {
  depends_on        = ["heroku_addon.ssl-addon"]
  count             = "${var.use_ssl ? 1 : 0}"
  app               = "${heroku_app.service-app.name}"
  certificate_chain = "${file("files/server.crt")}"
  private_key       = "${file("files/server.key")}"
}
```

This is doing a handful of things. First it is setting up an heroku app which
will conditionally have an SSL addon and a SSL certificate. Using the `count`
setting for a resource we can use our [HCL][hcl] conditional ternary syntax to
say when `use_ssl = false` it will be a `count = 0` and thus tells [Terraform][terraform]
not to create this resource and include it in the state or plan.

If you ran `terraform plan -var 'use_ssl=true'` it would plan out the resources
including the `heroku_addon.ssl-addon` and the `heroku_cert.ssl_certificate`.
And by default runnign `terraform plan` would have a state that only included
the `heroku_app.service-app` with no SSL resources considered.

## Conclusion

Using the basics of [HCL][hcl] conditionals and the `count` attribute for
Terraform resources we can pretty easily allow for even further dynamic
resource configuration. Even though it sort of goes against some of the ideas
behind Terraform one could see how using conditional resources is a useful trick
to employ when it comes up as a way to solve a specific need.

[hcl]: https://github.com/hashicorp/hcl
[terraform]: https://www.terraform.io
