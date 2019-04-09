---
categories:
- bash
- ci
- til
keywords:
- bash
- ci
- til
tags:
- til
- bash
- ci
comments: true
date: '2019-04-08'
title: Bash Say Command In CI
description: Sometimes you just need to 'say' it from a bash script. How to get around a stingy CI provider.
url: /2019/04/08/bash-say-in-ci
---
Sometimes you just need to `say` it from a bash script and some times your
CI provider won't be OK with that. Today I learned of one such provider, [CircleCI][circle]
who didn't want to play nicely with using `say`
<!--more-->

If you aren't familiar with the `say` unix command it is a tool to help convert
text to audible speech. I was recently writing some bash scripts with the goal
of being obnoxious enough to use the command to remind developers to update
their workstations. Since this affects a larger team there is CI set up to run
tests against the bash scripts using [Shpec][shpec].

While we were laughing at all the things we wanted to have the script say to outloud
from the office laptops we noticed the build went red. Much to our chagrin it
was the `say` command just hanging there silenced in some virtual cloud. Instead we
had to come up with a _special 'say'_ for just our CI builds.

```bash
SAY_CMD=say

if [[ ! -z $CI ]]; then
  SAY_CMD="echo Would have run: say "
fi
//
// later in the code
//
$SAY_CMD "well isnt that special?"
```

In [CircleCI][circle] they have some environment variables that are always there for
CI runs, such as the `$CI` variable that is being used to make the check. The script
is setting the `SAY_CMD=say` to be the original while in `$CI` we replace it with
an `echo` and prepend it with some useful information.

It's not fancy but it did the trick and the build went back to green. Our workstations
got a little noisier but we still have our test coverage. If you want to know more
about the say command check out [the manpage][manpage] for more info.

[circle]: https://circleci.com
[manpage]: http://manpages.ubuntu.com/manpages/bionic/man1/say.1.html
[shpec]: https://github.com/rylnd/shpec
