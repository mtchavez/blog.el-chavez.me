---
categories:
- fishshell
- bash
- developer tools
keywords:
- fishshell
- bash to fish
- fishshell fisherman
- developer tools
tags:
- fishshell
- bash to fish
- fishshell fisherman
- developer tools
series:
- fishshell
- developer tools
comments: true
date: '2018-05-22'
title: Switching From Bash To Fish
description: My surprisingly painless transition from years of bash to fish in one night.
url: /2018/05/22/bash-to-fish
---
I recently went through a painless transition from years of bash to fish shell
in one evening. My bash setup has been stale for quite some time. I am mainly
working in a bash terminal on a Mac and various Linux distributions. Bash, for
me, has always been a bit of a mess to sort out the quirks of writing up scripts,
loading in profile and configuration, and customizing the shell prompt. I had
always put up with the quirks up until the other day when I decided to take the
dive into [Fish Shell][fishshell].
<!--more-->

## Transitioning

Another common switch for people to make is changing to the latest text editor
of the year. Having done this in the past as well I knew going into my shell
switch that I would benefit from a similar approach as my past text editor switches.

1. Jump right in and fail
2. Run your current set up side by side
3. Look into popular projects or resources in the ecosystem
4. Reach out to people you know who already use it for advice

## The Setup Details

For a macOS centric setup I was surprised how little I had to do to get my years
of calloused bash setup and configuration covered with fish, and in a few ways exceeded.

### Installing Fish

[Fish][fishshell] is as simple as a `brew install fish` on macOS. The usual
installation options are available for other environments. One of the post
install messages you'll see from homebrew is how to update your system shells
to include Fish. Follow what it says by adding `/usr/local/bin/fish` to the
`/etc/shells` file. Additionally change your default shell to Fish with
`chsh -s /usr/local/bin/fish`

### Fisherman

One of the things I never realized I wanted with Bash is some kind of _sane_ way
to configure common functionality from others or different communities.
Plugins are one of the things that grab people's attention to switch from bash
to things like [ZSH][zsh] and [Fish][fishshell].

[Fisherman][fisherman] is what I found to be the simplest and easiest plugin
manager for Fish. It has a one line install with
`curl -Lo ~/.config/fish/functions/fisher.fish --create-dirs https://git.io/fisher`
and can be updated from itself going forward.

Outside of [Fisherman][fisherman] there is [Oh My Fish][omf], which borrows its
name from the popular [Oh My ZSH][oh-my-zsh] project for ZSH. Fisherman itself
is able to install any of the plugins that are a part of Oh My Fish so you won't
be left out choosing Fisherman for plugin management.

### Plugins

Installing and managing plugins with fisherman is straightforward. You can
install with `fisher install bass`. Additionally you can quickly remove with
`fisher remove nvm`. The base set of plugins I went with are few and completely
replaced all of my bash setup.

```
- omf/osx # macOS helper functions (probably not needed)
- omf/aws # AWS profile switcher (only for AWS users)
- fzf # Efficient key bindings (Requires fzf binary)
- edc/bass # Run bash from fish
- omf/foreign-env # Run commands in other envs
- omf/theme-scorphish # Theme
- nvm # Node version manager (Probably not needed)
- pipenv # Pipenv handling (Probably not needed)
- rbenv # Ruby version handling (Probably not needed)
```

### Themes

Another thing modern shells make easier than bash is being able to adopt themes
from others, or just theme in general. My bash prompt was always a little
depressing compared to others who invested more time to get nifty things injected
in their prompts. [Oh My Fish][omf] has a comprehensive [theme page][omf-themes]
that you an sift through to install one that catches your eye. Alternatively
you can look into how to theme something of your own creation.

Then with fisherman you can simply `fisher install some-theme` and it will be
applied to your shell.

## Gotchas and Learnings

1. Running bash scripts, both legacy and otherwise, is still really easy with
   the `bass` plugin. No need to convert those gnarly bash scripts over to fish
   just yet. Simply run `bass "./that-one-script.sh"`.
2. Exporting variables like `export MY_KEY='asdf'` is a little easier with
   `set -x MY_KEY asdf` where the `-x` is similar to _exporting_. You can _erase_
   the variable as well with `set -e MY_KEY`.
3. Inline environment variables for commands or scripts can take some getting
   used to. I've grown accustomed to the bash approach here doing `CACHE=false ./bin/runner`.
   The fish equivalent here is a littler clunkier, in my opinion, but still has a
   good feel and readable `env CACHE=false ./bin/runner`.
4. Configuration file lives in `~/.config/fish/config.fish` by default and there
   is a `~/.config/fish/functions` directory for shell functions like that of
   `fisher` for Fisherman.
5. Setting your `$PATH` is pretty much the same by doing `set PATH /usr/local/bin $PATH`
6. Args to your functions use `$argv` instead of `$1, $2` etc.
7. You can make functions with args using `-a`
    ```
    function foo -a bar
      echo $bar
    end
    ```

## Outcome

All in all I have barely scratched the surface of what [Fish][fishshell] can
really do. My main goal was to try out a new shell that had things like autocompletion,
themes, plugins, extensibility, and ease of use. Fish really does well with a
lot of these out of the box and adding [Fisherman][fisherman] on top for plugin
management makes things seamless. One of my key takeaways, and big reason for
writing this up, is that I was able to do this in a few hours one evening without
much pain. The next week I ran into one or two minor roadblocks which were sorted
out quickly and I was easily as productive, if not more, as with my previous bash
shell setup.

[fisherman]: https://github.com/fisherman/fisherman
[fishshell]: https://fishshell.com/
[omf]: https://github.com/oh-my-fish/oh-my-fish
[omf-themes]: https://github.com/oh-my-fish/oh-my-fish/blob/master/docs/Themes.md
[oh-my-zsh]: http://ohmyz.sh/
[zsh]: https://www.zsh.org/
