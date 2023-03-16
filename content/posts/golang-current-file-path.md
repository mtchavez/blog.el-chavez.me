---
categories:
- go
- golang
- til
keywords:
- go
- golang
- til
tags:
- go
- golang
- til
series:
- golang
- til
comments: true
date: '2013-05-17'
title: Golang Current File Path
description: How to get the current file path in golang
url: /2013/05/17/golang-current-file-path
---
I recently needed to get the current file absolute path from a go file.
You first need to get the runtime package which is a part of Go

<!--more-->


```go
import "runtime"
```

Next you can use the `Caller` method and capture the filename. We need to
give this function a `1` to tell it to skip up a caller. You can read more
about the function [here](http://golang.org/pkg/runtime/#Caller)

```go
_, filename, _, ok := runtime.Caller(1)
```

The filename will be the path up to the current directory of the file that
calls this function. The `ok` is to check if the function call was able to
find the information requested.

So in practice if you wanted to get a config file up a directory and in a
config directory you could do the following

```go
filepath := path.Join(path.Dir(filename), "../config/settings.toml")
```
