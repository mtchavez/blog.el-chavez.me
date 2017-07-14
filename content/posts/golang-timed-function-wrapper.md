---
categories:
- go
- golang
keywords:
- go
- golang
- golang timing
- golang interfaces
tags:
- go
- golang
- golang timing
- golang interfaces
comments: true
date: '2013-08-09'
title: Golang Timed Function Wrapper
description: Example of timing function calls in golang
url: /2013/08/09/golang-timed-function-wrapper
---
Wrote this quick and probably dirty wrapper for timing functions in Go.
`TimedReturn` returns an `interface{}` in case a return value is needed
from whatever you are wrapping.

<!--more-->

```go
package main

import (
  "fmt"
  "time"
)

type wrapped func()
type wrappedReturn func() interface{}

func Timed(fn wrapped, key string) {
  start := time.Now().Unix()
  fn()
  end := time.Now().Unix()
  fmt.Printf("Time: %d, Key: %s\n", end-start, key)
}

func TimedReturn(fn wrappedReturn, key string) interface{} {
  start := time.Now().Unix()
  resp := fn()
  end := time.Now().Unix()
  fmt.Printf("Time: %d, Key: %s]n", end-start, key)
  return resp
}

func main() {
  fn := func() {
    fmt.Println("Hello from wrapped function!")
    time.Sleep(time.Duration(1) * time.Second)
  }
  Timed(fn, "go.playground")

  fn2 := func() interface{} {
    fmt.Println("Hello from wrapped function with return!")
    time.Sleep(time.Duration(2) * time.Second)
    return []int{3}
  }
  returned := TimedReturn(fn2, "go.playground")
  fmt.Println("TimedReturn got:", returned.([]int))
}
```
