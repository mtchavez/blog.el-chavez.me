---
categories:
- golang
- til
keywords:
- golang
- golang print bytes
- golang bytes debug
- golang print byte buffer
- debug golang bytes slice
- debug golang bytes array
tags:
- golang
- til
series:
- golang
- til
comments: true
date: '2019-08-02'
title: Golang Debug Bytes
description: Golang debugging your bytes and byte buffers.
url: /2019/08/02/golang-debug-bytes
featured_image: images/featured/debug.jpg
images:
- images/featured/debug.jpg
---
When working with raw [bytes][bytes] in [Golang][golang] it can be
a little difficult to debug. If you are new to the language or just
want to quickly check some data as a human readable text blob it is useful
to have a technique for doing this.
<!--more-->

For a _today I learned_ moment I found a useful way to get a quick debugging
of those pesky bytes. Even when trying to debug from your tests you can
get a good output of the data you are trying to look into. The technique
involves making a new Buffer that will write to _STDOUT_.

```golang
package main

import (
	"bytes"
	"fmt"
	"io"
	"os"
)

func main() {
	message := []byte("My super secret message for you to read!\n")
	io.Copy(os.Stdout, bytes.NewBuffer(message))
	fmt.Printf("%+v\n", message)
}
```

Which results in the following output:

```
My super secret message for you to read!
[77 121 32 115 117 112 101 114 32 115 101 99 114 101 116 32 109 101 115 115 97 103 101 32 102 111 114 32 121 111 117 32 116 111 32 114 101 97 100 33 10]
```

This technique works because the new bytes Buffer is set up with both write
and read methods. If you notice the `Printf` line attempting to debug the
same bytes is actually printing out the raw bytes. Some might notice that you
can easily wrap that message in a string cast as `fmt.Printf("%+v\n", string(message))` which will definitely work. The `io.Copy` technique comes in handy
if you aren't getting log or fmt print statements printed out, such as from
tests. Since I found this useful when recently needing to debug some bytes
I thought I would share.

[bytes]: https://golang.org/pkg/bytes/
[golang]: https://golang.org
