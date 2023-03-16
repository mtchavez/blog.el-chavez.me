---
categories:
- ansible
- testing
- devops
- infrastructure as code
keywords:
- ansible
- ansible galaxy
- ansible galaxy role testing
- ansible test kitchen
- devops
- infrastructure as code
tags:
- ansible
- ansible galaxy
- ansible galaxy role testing
- ansible test kitchen
- devops
- infrastructure as code
series:
- ansible
- devops
- infrastructure as code
comments: true
date: '2016-02-16'
title: Ansible Galaxy – Testing Roles with Test Kitchen
description: Writing fully tested Ansible roles for Galaxy with Test Kitchen across multiple platforms
url: /2016/02/16/ansible-galaxy-test-kitchen
---

[Ansible][1] is a provisioning tool to easily help you get your infrastructure
under control. One of the key elements in Ansible is a `role`. There are public
roles to get you started quickly with Ansible over at [Ansible Galaxy][2]. One
thing Ansible is sort of lacking is a strong testing approach for open source
roles.

<!--more-->

Other technologies like [Chef][3] have this approach to test drive the
code and tools that provision your infrastructure. Luckily there has been some
work to extend some of those very tools to test your Ansible roles as well.

To get started we will need a handful of dependencies:

> 1. A working Python install with [Ansible][4] installed
> * A working Ruby install with [bundler][5] installed
> * [Docker][6] installed and running. Please see [install instructions][7].
> * Some knowledge on Ansible itself and creating Galaxy roles.
> * Also some knowledge of Rspec and a Ruby dev environment

## Adding needed gems

First we can start by initializing bundler for the role with `bundler init`.
Then we can add our dependencies to the `Gemfile`.

```ruby
source 'https://rubygems.org'

group :test do
  gem 'kitchen-ansible'
  gem 'kitchen-docker'
  gem 'test-kitchen'
end
```

The dependencies here are adding [Test Kitchen][8] with the ansible and docker
hooks since by default this is used with Chef and [Vagrant][9]. Make sure to
install the dependencies afterwards with `bundle install`

## Kitchen setup

Once kitchen dependencies are installed we can initialize the role for the Test
Kitchen with `bundle exec kitchen init`. This will create a `.kitchen.yml` file,
which we want to update to be the following:

```yaml
---

driver:
  name: docker

platforms:
  - name: "ubuntu-14.04"

verifier:
  name: busser
  plugin:
    - Ansiblespec

suites:
  - name: default
    provisioner:
      name: ansible_playbook
      playbook: role.yml
      additional_copy_path:
        - "."
```

The gist of what this is doing is telling kitchen to use the docker driver,
with a platform of Ubuntu 14.04 LTS, a verifing step using the Ansiblespec plugin,
and a default test suite that will run a playbook named `role.yml`. The most
important thing at the moment is the `additional_copy_path`. At the moment testing
an Ansible Galaxy role doesn't just work out of the box with `kitchen-ansible`.
By specifying the copy path to be the role directory you get it copied into the
provisioner which can then be ran as a normal role within a playbook.

## Kitchen Ansible setup

Kitchen Ansible is where most of the magic happens to allow Test Kitchen to be used
in place of Chef. See [the repo][10] for more information on setup, updates, and
configuration. Start by making the needed test directories and files to run our
default test suite. Your test directory structure should look like so:

```
test/
└── integration
    └── default
        └── ansiblespec
            ├── Gemfile
            └── config.yml
```

The `config.yml` file for the default suite should be filled out with this:

```yaml
---

-
  playbook: role.yml
  inventory: hosts
  kitchen_path: "/tmp/kitchen"
  pattern: "spec"
  user: root
```

Where the `role.yml` is a playbook in your Galaxy role that includes itself with
variables and tasks.

```yaml
---

- name: Test my role
  hosts: all
  sudo: yes
  roles:
    - ""
  vars_files:
    - "defaults/main.yml"
    - "vars/main.yml"
  tasks:
    - include: "tasks/main.yml"
  handlers:
    - include: "handlers/main.yml"
```

**At time of writing this will break without the `roles` section!**

## Writing your specs

Since Test Kitchen uses [Rspec][11] we will need to set this up with a `spec_helper`
and our `default_spec.rb` for our default test suite in a `spec` directory:

```
spec
├── default_spec.rb
└── spec_helper.rb
```

Where a `spec_helper.rb` would look something like this, minus any SSH setup which
you can see more on at the [kitchen-ansible][10] repository.

```ruby
require 'rubygems'
require 'bundler/setup'

require 'serverspec'
require 'pathname'
require 'net/ssh'

RSpec.configure do
  set :host, ENV['TARGET_HOST']
  set :request_pty, true
end
```

A contrived `default_spec.rb` might look something like so:

```ruby
require_relative './spec_helper.rb'

describe 'my galaxy role' do
  describe group('baz') do
    it { should exist }
  end

  describe user('foobar') do
    it { should exist }
  end

  describe package('role-package') do
    it { should be_installed }
  end

  describe file('/etc/myapp/app.conf') do
    it { should be_file }
  end

  describe port(8000) do
    it { should be_listening }
  end

  describe process('myprocess') do
    it { should be_running }
  end
end
```

## Running your role tests

With everything in place we have Test Kitchen set up to use our ansible role
to provision an Ubuntu machine within Docker and verify with our serverspec
test. Now we can run the tests with `bundle exec kitchen test`. This will
spin up a docker image with Ubuntu installed. Chef will be installed to use
this version of Ruby for any dependencies. Ansible will be installed and used
to provision the container with your `role.yml` playbook. Then rspec will be
ran to run the default test suite and your `default_spec.rb` file.

## Some shortcomings

Currently you need to define an empty `roles` key in your playbook being ran.
Kitchen ansible was mainly built to run against an ansible project with multiple
roles rather than a Galaxy role. This may change in the future, making this process
easier.

The `spec` pattern is being used here to workaround a path issue with where
the verifier is looking for spec files. This means the spec files matching
`spec/*_spec.rb` will be executed for every test suite at the moment. It would
be nice to have a suite directory with spec files per suite, similar to a per
role suite in the normal testing pattern.

Using the `additional_copy_path` had to be used to get the galaxy role into
the container where provisioning needed to happen. Ideally there would be a nicer
way to say your role that is being tested is the current directory or is a galaxy
role to avoid this.

## Kitchen Ansible love

Overall this is a great start to getting some test coverage for an ansible
galaxy role. It helps shorten the gap to something like Chef that has a community
that is focused on testing their open source contributions. This also helped me
with a role where someone contributed changes to support a non-ubuntu platform.
Now tests can be added for the new platform to ensure things don't break for either
when added in and going forward.

[1]: https://www.ansible.com/
[2]: https://galaxy.ansible.com/
[3]: https://www.chef.io/
[4]: https://pypi.python.org/pypi/ansible
[5]: http://bundler.io/
[6]: https://www.docker.com/
[7]: https://docs.docker.com/engine/installation/
[8]: http://kitchen.ci/
[9]: https://www.vagrantup.com/
[10]: https://github.com/neillturner/kitchen-ansible
[11]: http://rspec.info
