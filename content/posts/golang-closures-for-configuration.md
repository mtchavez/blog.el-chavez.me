---
categories:
- golang
- refactoring
keywords:
- golang
- golang closures
- golang refactoring
- golang closures for configuration
- golang functional programming with closures
tags:
- golang
- refactoring
comments: true
date: '2019-08-25'
title: Golang Closures For Configuration
description: Using closures to refactor your struct configuration in golang.
url: /2019/08/25/golang-closures-for-configuration
---
One common code smell is creating functions with a long list of parameters. Adding
a new function usually starts out optimistically with a few inputs or known state
that is needed. Over time you start adding more state and extending functionality
of existing code and quickly it turns into something that is no longer maintainable
or causes issues of other places in the codebase needed a larger list of dependencies
and state to call these codepaths. Let's look at one approach you can take with
golang.
<!--more-->

## New()

In Golang packages and structs generally follow a pattern of creating `New` functions
as an entrypoint to a package or for initializing structs to be used. For simple
packages and structs this likely won't need many inputs. For example:

```go
package service

type Service struct {
  username string
  password string
}

func New(username, password string) *Service {
  return &Service {
    username: username,
    password: password,
  }
}
```


## More Complex Structures

Here is an example of a data structure that has more state needed to be initialized.

```go
package main

type bucket []uint

type Filter struct {
  sync.Mutex
  buckets       []bucket
  bucketEntries uint
  bucketTotal   uint
  capacity      uint
  count         uint
  kicks         uint
  boost         bool
  keyName       string
}

func New(buckets []bucket, bucketEntries uint, bucketTotal uint, capacity uint, count uint, kicks uint, boost bool, keyName string) *Filter {
  return &Filter {
    buckets: buckets,
    bucketEntries: bucketEntries,
    bucketTotal: bucketTotal,
    capacity: capacity,
    count: count,
    kicks: kicks,
    boost: boost,
    keyName: keyName,
  }
}
```

As you can see if you were to expose these attributes to a `New()` function for
creating a new `Filter` you are starting with up to 8 parameters for the first time
you write this code. Some refactoring options might be to break up different pieces
of the attributes like the `bucket` settings into their own `BucketConfiguration`
structure. Another could be to expose all the attributes and let them be configurable
by callers outside the package, but this has large implications on how to control
those attributes and it may be undesireable to have them exposed. So what other
options are there?

## Closures for Configuration

Closures are one option to help define a way of controlling the inputs. What exactly
is a closure then? They can be thought of as a way for defining functions that have
access to the outer scope of that function. Closures are often refered to as
_anonymous functions_, but in reality, a closure is an instance of a function that
is bound to some values or outer scope. What does this look like in go?

```go
package main

type ConfigOption func(*Filter)

func BucketTotal(total uint) ConfigOption {
  return func(f *Filter) {
    f.bucketTotal = total
  }
}
```

Using the previous example of a `Filter` we define a new type called `ConfigOption`
that is a function signature of `func(*Filter)`. This means that any function which
takes a filter is a valid value to pass around. The _scope_ being taken in here is
the `total` passed into the `BucketTotal` function that is closing the inner returned
function value.

## New with Configuration Options

How can we use this for cleaning up our parameter list to creating a `Filter`?
For each attribute we can now expose functions that let you use the package to
configure a `Filter` as needed. This would look like:

```go
package main

type ConfigOption func(*Filter)

func BucketEntries(entries uint) ConfigOption {
  return func(f *Filter) {
    f.bucketEntries = entries
  }
}

func BucketTotal(total uint) ConfigOption {
  return func(f *Filter) {
    f.bucketTotal = total
  }
}

func Kicks(kicks uint) ConfigOption {
  return func(f *Filter) {
    f.kicks = kicks
  }
}

func Boost(boost bool) ConfigOption {
  return func(f *Filter) {
    f.boost = boost
  }
}

func KeyName(keyName string) ConfigOption {
  return func(f *Filter) {
    f.keyName = keyName
  }
}
```

And to use these filter configuration options the `New` function becomes simplified
to taking a list of these options. Since they are function closures themselves
they simply get called with a filter.

```go
package main

func NewFilter(opts ...ConfigOption) (filter *Filter) {
  filter = &Filter{}
  for _, option := range opts {
    option(filter)
  }
  return
}
```

## Putting It All Together

All the pieces exist now to have a refactored `New` function with extensible
parameters with a simple and easy to understand implementation.

```go
package main

import (
  "fmt"
  "sync"
)

const (
  // Entries per bucket (b)
  defaultBucketEntries uint = 24
  // Bucket total (m) defaults to approx. 4 million
  defaultBucketTotal uint = 1 << 22
  // Default attempts to find empty slot on insert
  defaultKicks uint = 500
)

type ConfigOption func(*Filter)

type bucket []uint

type Filter struct {
  sync.Mutex
  buckets       []bucket
  bucketEntries uint
  bucketTotal   uint
  capacity      uint
  count         uint
  kicks         uint
  boost         bool
  keyName       string
}

func BucketEntries(entries uint) ConfigOption {
  return func(f *Filter) {
    f.bucketEntries = entries
  }
}

func BucketTotal(total uint) ConfigOption {
  return func(f *Filter) {
    f.bucketTotal = total
  }
}

func Kicks(kicks uint) ConfigOption {
  return func(f *Filter) {
    f.kicks = kicks
  }
}

func Boost(boost bool) ConfigOption {
  return func(f *Filter) {
    f.boost = boost
  }
}

func KeyName(keyName string) ConfigOption {
  return func(f *Filter) {
    f.keyName = keyName
  }
}

func NewFilter(opts ...ConfigOption) (filter *Filter) {
  filter = &Filter{}
  filter.configureDefaults()
  for _, option := range opts {
    option(filter)
  }
  return
}

func (f *Filter) configureDefaults() {
  f.bucketEntries = defaultBucketEntries
  f.bucketTotal = defaultBucketTotal
  f.kicks = defaultKicks
}

func main() {
  filter := NewFilter()
  fmt.Printf("Filter: %+v\n", filter)

  configuredFilter := NewFilter(
    Kicks(uint(30)),
    Boost(false),
    KeyName("2019-08-25-filter"),
  )
  fmt.Printf("Configured Filter: %+v\n", configuredFilter)
}
```

Creating a new filter now has the ability to pass in closures as options to
set up a new filter. There is a new part that sets up some defaults using
constants for known sensible defaults to use with a `Filter`. Creating new filters
is as simple as `NewFilter()` or can be the entire list of attributes here. To add
new configurations to the list won't change the `NewFilter` function signature
so it is as extensible as it needs to be.

## Conclusion

There are some wins you get by refactoring your parameter list to use closures. The
function to create a `NewFilter` here is simple and takes any number of configurations
that you want to support. A downside might be the extra code needed to write up
the closures for each attribute.
