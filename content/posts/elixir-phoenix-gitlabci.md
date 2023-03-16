---
categories:
- elixir
- gitlab
- testing
keywords:
- elixir
- gitlab
- testing
- gitlab-ci
- phoenix framework
tags:
- elixir
- gitlab
- testing
- gitlab-ci
- phoenix framework
series:
- elixir
- gitlab
- testing
- ci-cd
comments: true
date: '2017-07-13'
title: Elixir/Phoenix with GitlabCI
description: Setting up your Elixir and Phoenix apps using GitlabCI for tests, linting, and coverage.
url: /2017/07/13/elixir-phoenix-gitlabci
---

[Gitlab][gitlab] has been approaching the hosted VCS solution with a more robust
and thought out handling of the entire release pipeline for code instead of
the basic features of a git flow approach. Enter [GitlabCI][ci].

<!--more-->

[GitlabCI][ci] is just one piece of the modern release pipeline that is offered
from [Gitlab][gitlab]. Another modern piece of technology in Software Engineering
has also been [Elixir][elixir], the functional programming language built on top
of [Erlang][erlang] and OTP with a ruby-inspired syntax. The creators of the
language came form the ruby and rails world and have also made a web framework
called [Phoenix][phoenix] as a good introduction to the power of [Elixir][elixir].

So how can we move into the modern development landscape and bring these two
worlds together, and will it bring the fuzzy warm feelings? In this post we will:

> 1. Look into some setup needed for Elixir and/or Phoenix to run tests
> * Getting your test coverage
> * Running a linter against your code
> * Setting up a project with GitlabCI
> * Tying it all together to get your project running through GitlabCI

## Setting up testing

This assumes some prior knowledge of [Phoenix][phoenix] and [Elixir][elixir] as
well as some of the tooling around the two like [Hex][hex] and [Mix][mix].
We will start out by creating a new Phoneix app and running the tests.

```bash
$ mix phoenix.new testly
$ cd testly
$ mix test
```

If all went well you should see some output similar to:

```bash
....

Finished in 0.06 seconds
4 tests, 0 failures

Randomized with seed 388184
```

So as you can see testing is a first class citizen with both Elixir and Phoenix.
If you've come from other languages there is usually a separate step for test
framework setup and writing tests with additional tools for mocking, stubbing,
running in a browser etc. Elixir has [ExUnit][exunit] which Phoenix uses
so test setup here will be simply generating a new Phoenix app.

## Test coverage

Once your app has tests you are bound to wonder how much of your code is being
covered and when someone adds new code without tests you can see some coverage
metric go down. Generating test coverage is another simple thing here. One theme
with Elixir is it leverages a lot of existing Erlang solutions and tools, here
is no exception. From the test help output under coverage you can see:

```
# Coverage
[...]
By default, a very simple wrapper around OTP's cover is used
```

So running `mix test --cover` will generate fairly rudimentary html files for
your code where you can see un-covered lines. Because this is a little rough
for getting an overall coverage we will utilize a [Hex][hex] Elixir package
to get a proper coverage output.

If you open up `mix.ex` you can add `excoveralls` to the dependencies as so:

```elixir
defp deps do
  [
    {:phoenix, "~> 1.2.4"},
    {:phoenix_pubsub, "~> 1.0"},
    {:phoenix_ecto, "~> 3.0"},
    {:postgrex, ">= 0.0.0"},
    {:phoenix_html, "~> 2.6"},
    {:phoenix_live_reload, "~> 1.0", only: :dev},
    {:gettext, "~> 0.11"},
    {:cowboy, "~> 1.0"},

    # Test

    {:excoveralls, "~> 0.7", only: :test}
  ]
end
```

And add some stup to the project in `mix.ex` as well

```elixir
def project
  [app: :testly,
    [...]
    # Test
    test_coverage: [tool: ExCoveralls],
    preferred_cli_env: [
      "coveralls": :test,
      "coveralls.detail": :test,
      "coveralls.post": :test,
      "coveralls.html": :test
    ],
    [...]
  ]
end
```

You can read more on the [ExCoveralls][excoveralls] project page on how to set
up your app.

Now we can run `mix coveralls` to get a test output with a total coverage as so

```
Finished in 0.08 seconds
4 tests, 0 failures

Randomized with seed 276987
----------------
COV    FILE                                        LINES RELEVANT   MISSED
 75.0% lib/testly.ex                                  31        4        1
  0.0% lib/testly/endpoint.ex                         42        0        0
  0.0% lib/testly/repo.ex                              3        0        0
  0.0% test/support/channel_case.ex                   43        4        4
100.0% test/support/conn_case.ex                      44        4        0
  0.0% test/support/model_case.ex                     65        6        6
  0.0% web/channels/user_socket.ex                    37        0        0
100.0% web/controllers/page_controller.ex              7        1        0
  0.0% web/gettext.ex                                 24        0        0
 50.0% web/router.ex                                  26        2        1
  0.0% web/views/error_helpers.ex                     40        5        5
100.0% web/views/error_view.ex                        17        1        0
  0.0% web/views/layout_view.ex                        3        0        0
  0.0% web/views/page_view.ex                          3        0        0
  0.0% web/web.ex                                     81        1        1
[TOTAL]  35.7%
----------------
```

## Linting your code

If you aren't a fan of linters for your code or making sure there are some
consistent code styles enforced you can skip to the next part. I have been
using the [Dogma][dogma] package to check code so add it to your dependencies
first:

```elixir
defp deps do
  [
    # Dev
    {:dogma, "~> 0.1", only: :dev}
  ]
end
```

And run with `mix dogma`. There should be a handful of errors from a fresh
Phoenix project so you can choose to configure [Dogma][dogma] to ignore
certain rules or fix them yourself. See [the configuration][dogma-conf] doc
for more information.

## Integration with GitlabCI

A good starting point will be [the docs][ci] to familiarize yourself with what
GitlabCI can do. If you've used other services like [TravisCI][travis] or
[CircleCI][circle] you should be familiar with the YAML configuration approach
and containerized builds that can be parallelized. With that let's add a
`.gitlab-ci.yml` file to the project with the following:

```yaml
image: elixir:1.4
services:
  - postgres:9.6
variables:
  MIX_ENV: "test"
before_script:
  - apt-get update
  - apt-get install -y postgresql-client
  - mix local.hex --force
  - mix local.rebar --force
  - mix deps.get --only test
  - mix ecto.reset
test:
  script:
    - mix test
```

This setup is configuring GitlabCI to use the `elixir:1.4` docker image for our
tests to run in. The `services` section is configuring the required services
dependencies for our build, in this case Postgres for Phoenix and Ecto.
We are also setting the environment for [Mix][mix] to be in test mode. Other
than that we have a handful of commands in the `before_script` that set up the test
environment to get all the dependencies and reset the test DB with `mix ecto.reset`.

If you check this in from a feature branch and open a merge request against your
repository you should see your GitlabCI build in the pipeline. If all goes
well there will be a successful build.

## Tying Everything Together with GitlabCI

The basic example is nice since it is fairly simple and will get us running
tests with GitlabCI but you may be wondering why there is no test coverage
or linting going on since we made sure to set all those things up earlier.
GitlabCI allows you to create fairly complex build rules and we will only
scratch the surface with adding coverage and linting to our basic example.

If you are following along with the code examples you can replace the `.gitlab-ci.yml`
with this:

```yaml
variables:
  MIX_ENV: "test"

stages:
  - build
  - test
  - post-test

.job_template: &job_definition
  image: elixir:1.4
  before_script:
    - apt-get update
    - apt-get install -y postgresql-client
    - mix local.hex --force
    - mix local.rebar --force
    - mix deps.get --only test

test:
  <<: *job_definition
  stage: test
  services:
    - postgres:9.6
  script:
    - "mix ecto.reset"
    - "mix coveralls.html | tee cov.out"
  artifacts:
    paths:
      - cov.out
      - cover/

dogma:
  <<: *job_definition
  stage: test
  script:
    - mix dogma
  variables:
    MIX_ENV: "dev"

coverage:
  image: alpine
  stage: post-test
  script:
    - cat cov.out
  coverage: '/\[TOTAL\]\s+(\d+\.\d+%)$/'
```

Things suddenly got a lot more involved but really we are doing a lot here with
still a small amount of code, even being DRY with some YAML tricks. Briefly lets
go through the changes here. First we have replaced the top level configuration
with jobs for test, dogma, and coverage. GitlabCI treats each one of these as
a separate job. You may have noticed there is also a new key of `stages`. Jobs
can run in specific stages and jobs in the same stage will all run in parallel
at the same time. So what we have done here is say we have two jobs running in
our `test` stage, the first being the default `test` job and a custom job of
`dogma` to run our linting. Our last job is `coverage` which is running in a
`post-test` stage which will wait for all the test jobs to have run before
gathering the coverage.

Another change here is we are re-using some setup code with our `job_template`
to set up the test jobs with the same image and before script. This allows us
to share a common environment across jobs. Our test job is also using the
postgres service, resetting the test DB, and exporting coverage artifacts to
be used by later stages, namely the coverage job.

Once the test stage has finished the `coverage` job will run and have access
to our coverage artifacts from the tests build. We use that to tell GitlabCI
how to parse our coverage output. If everything passes you should be able
to add some badges to your `README` for build status and coverage as so

```
[![build status](https://gitlab.com/your-user/testly/badges/master/build.svg)](https://gitlab.com/your-user/testly/commits/master)
[![coverage report](https://gitlab.com/your-user/testly/badges/master/coverage.svg)](https://gitlab.com/your-user/testly/commits/master)
```

## Wrapping Up

As you can see both Elixir and GitlabCI are fairly easy to integrate together.
With [Elixir][elixir] and [Phoenix][phoenix] there is a lot out of the box as well
as some basic packages with some modern development practices. [GitlabCI][ci]
shows some promise with simplicity as well as more complex build pipelines. There
is even more that is possible to go deeper into the release cycle of code on
Gitlab using [review apps][gitlab-ra], [docker registry][gitlab-registry] integration,
and [continuous deployment][gitlab-cd].

[ci]: https://docs.gitlab.com/ce/ci/
[dogma]: https://github.com/lpil/dogma
[dogma-conf]: https://github.com/lpil/dogma/blob/master/docs/configuration.md
[elixir]: https://elixir-lang.org
[erlang]: http://www.erlang.org
[excoveralls]: https://github.com/parroty/excoveralls
[exunit]: https://hexdocs.pm/ex_unit/ExUnit.html
[gitlab]: https://about.gitlab.com
[gitlab-cd]: https://about.gitlab.com/features/gitlab-ci-cd/
[gitlab-ra]: https://about.gitlab.com/features/review-apps/
[gitlab-registry]: https://docs.gitlab.com/ee/README.html
[hex]: https://hex.pm
[mix]: https://elixir-lang.org/getting-started/mix-otp/introduction-to-mix.html
[phoenix]: http://www.phoenixframework.org
[travis]: https://travisci.org
[circle]: http://circleci.com
