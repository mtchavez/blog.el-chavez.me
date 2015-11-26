---
categories:
- vagrant
keywords:
- vagrant
- vagrant cloud
- custom vagrant cloud host
- vagrant box version
comments: true
date: '2015-01-31'
title: Custom Vagrant Cloud Versioned Box Host
description: How to use a custom hosted Vagrant box to mimic how Vagrant Cloud looks for boxes and handles box versions
url: /2015/01/31/custom-vagrant-cloud-host
---

With the recent addition of [Atlas](https://atlas.hashicorp.com) to the [Hashicorp](https://hashicorp.com)
arsenal, [Vagrant](https://www.vagrantup.com) got an update to be integrated into Atlas for hosting your
VM boxes and handling versioned updates. If you are still looking to have your boxes versioned
and are hosting them yourself, or your company has them private, you can still achieve versioning
your boxes with the latest Vagrant (1.7.2) and some manual work. In this post I will go through:

>1. Basics of building a Virtualbox Vagrant box, just enough to follow along.
>2. Building a box metadata file, used to resolve box versions and download URLs.
>3. Hooking everything up with your Vagrantfile.

<!--more-->
## Building a Box

If this topic is new to you please review [the docs](https://docs.vagrantup.com/v2/boxes/base.html), as this is not a new part
of vagrant and is provider specific. For simplicity we will use [VirtualBox](https://www.virtualbox.org/)
in these examples.

Please make sure you have the most recent Vagrant (1.7.2) and VirtualBox (4.3.20) beforehand.
We will need a basic `Vagrantfile` to start out with, or you can use one of your own.

{{<highlight ruby>}}
# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = '2'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # Base box from Atlas
  config.vm.box = 'ubuntu/trusty64'

  # Virtualbox VM settings
  config.vm.provider :virtualbox do |v|
    v.name = 'custom-box'
    v.cpus = 2
    v.memory = 4096
    opts = ['modifyvm', :id, '--natdnshostresolver1', 'on']
    v.customize opts
  end
end
{{</highlight>}}

This setup gives us an Ubuntu 64-bit Trusty box which will be pulled from Atlas to
build our VM. Worth noting is the name of our VM in Virtualbox is set to `custom-box`.
First we need to bring up the VM so it gets created if it hasn't already been.

```
$ vagrant up --provider virtualbox
```

Now we can use Vagrant's built in tool to build a box from the Virtualbox VM we just created.
In your terminal go to the directory of your project where your `Vagrantfile` is and run the
command to build the box.

```
$ vagrant package --base custom-box --output custom-box-0.0.1.box
```

This may take some time depending on if you have provisioned your box with anything extra.
The comman is telling Vagrant to package our box using our Vagrantfile. It will look up a VM
in Virtualbox named `custom-box` and we are naming our box `custom-box-0.0.1`. If this succeeds
you should see a box in your directory named `custom-box-0.0.1.box`.

This box file will need to be hosted somewhere so we can point to it in our box manifest file for
each version of the box. For the rest of the examples I will assume it is hosted on `example.com`.

## Box Metadata JSON

Vagrant, and Vagrant Cloud, uses a `metadata.json` file to determine where to download the box, the
versions available for a box and what providers the box is valid for. We will need to manage this
file in order to host our own versioned boxes outside of Vagrant Cloud. Here is an example
metadata file:

{{<highlight json>}}
{
    "name": "custom-box",
    "description": "My Custom Ubuntu 14.04 64-bit Box",
    "versions": [
        {
            "version": "0.0.1",
            "status": "active",
            "providers": [
                {
                    "name": "virtualbox",
                    "url": "https://example.com/vagrant/boxes/custom-box-0.0.1.box",
                    "checksum_type": "sha256",
                    "checksum": "d955cka5ce671de0be9846956a8954796e8ac42e5166847429951a7301fb7d42"
                }
            ]
        }
    ]
}
{{</highlight>}}

This example is defining a box which we have named `cusom-box`. This is equivalent to the
base ubuntu box we used which was named `ubuntu/trusty64`. This could be named a little better
such as scoped by project or company ie. `project-foo/trusty64`, `company-bar/api-box`. This box
has a description and then an array of all versions for the box.

The versions are where everything is really defined. Each version is a hash that contains: a version number,
a status, and an array of providers with information on each box specific to the provider. Since we are
using Virtualbox only we just have a single entry here with the URL of our box and a checksum to apply to
the download for verification. If we wanted to add extra versions it is as simple as adding another dictionary to our versions list, with
all the details filled out of course.

This file needs to be hosted somewhere as well so we will assume it is on our `example.com`
domain. Once you have your box and metadata file hosted we can now tie this all together with our
Vagrantfile.

## Hooking Everything Up

Firs we need to update our `Vagrantfile` so that it knows about our new versioned box we
are hosting outside of Atlas.

{{<highlight ruby>}}
# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = '2'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = 'custom-box'
  config.vm.box_version = '0.0.1'
  config.vm.box_url = 'http://example.com/vagrant/boxes/custom/metadata.json'

  # Virtualbox VM settings
  config.vm.provider :virtualbox do |v|
    v.name = 'custom-box'
    v.cpus = 2
    v.memory = 4096
    opts = ['modifyvm', :id, '--natdnshostresolver1', 'on']
    v.customize opts
  end
end
{{</highlight>}}

The changes to note here is we are using the name of our box now instead of the ubuntu name, `custom-box`.
We also have added a `config.vm.box_url` pointing to our hosted box metadata file and the version
we want to use is set with `config.vm.box_version`.

What is happening here for this to work is Vagrant pulls the metadata file down and checks what boxes it
knows about and matches that to what you have defined in your `Vagrantfile`. If everything is set up correctly
we should be able to do a `vagrant up`, ensuring the VM is already halted. This should pull the new box
down from the url for the version and provider defined in the metadata file. Now you have your own
custom hosted and versioned Vagrant box outside of Atlas.
