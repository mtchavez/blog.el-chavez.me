---
categories:
- golang
- golang tabwriter
- golang pkg
keywords:
- golang
- golang tabwriter
- golang print aligned text
- golang pkg
tags:
- golang
- golang tabwriter
- golang print aligned text
- golang pkg
comments: true
date: '2019-05-05'
title: Golang Printing Tabstopped Text into Aligned Columns
description:
url: /2019/05/05/golang-tabwriter-aligned-text
---
One of the strengths of [Golang][golang] as a language is it has a pretty strong standard
library of packages out of the box. Things like the [httptest][httptest] package and
even the [http][http] package is strong enough that there are countless http servers
open sourced built on top of it. One of the hidden convenient packages I've used is
the [tabwriter][tabwriter] to help print out tabstopped text into aligned text.
<!--more-->

If you have written any kind of command line tools in go printing out results or output
can be tedious to format with dynamic lenghts of the output. The [tabwriter][tabwriter] package
in Go is a way to help with that as a standard built-in to the language. First you start out
by creating the writer itself:

```go
package main

import (
	"os"
	"text/tabwriter"
)

func main() {
	writer := tabwriter.NewWriter(os.Stdout, 0, 8, 1, '\t', tabwriter.AlignRight)
}
```

The `NewWriter` function takes in an `io.Writer` compatible type, which we will use _STDOUT_.
Following that are the different spacing settings, first is the min cell width, next is the
width of the tab characters in spaces, last is the padding added to each cell before the length
is computed. After that is the character to use for the padding which is a `\t` tab character
here. The last input is a modifier flag for the formatting of text, such as alignment.

Now lets use the writer to add some content to display connection info for sites. We will want
to display a hostname, a port, along with a username/password combination.

```go
package main

import (
	"fmt"
	"os"
	"text/tabwriter"
)

func main() {
	writer := tabwriter.NewWriter(os.Stdout, 0, 8, 1, '\t', tabwriter.AlignRight)
	fmt.Fprintln(writer, "host\tport\tuser\tpassword")
	fmt.Fprintln(writer, "localhost\t:4000\tadmin\tadmin123")
	fmt.Fprintln(writer, "admin.productionapp.com\t:43\tprod-admin\th^3asd2#r0ealk")
	writer.Flush()
}
```

Running this should give the output below:

```
host			port	user		password
localhost		:4000	admin		admin123
admin.productionapp.com	:43	prod-admin	h^3asd2#r0ealk
```

As you can see the alignment of the columns by tabstop are handled for you depending on the
length calculation of the content between the tabstops. We have to use `fmt.Fprintln` here
to write to the writer directly with out lines to be formatted by the _tabwriter_. Try
playing around with some of the configurations to see how each option affects the output
and formatting.

The code here is pretty simple to understand and allows for customization and all of this is
built into the standard libary of packages in [Golang][golang] which is nice. If you have ever
had to implement this yourself or need to install 3rd-party packages to achieve this you will
appreciate having this available to you at no extra cost.

[golang]: https://golang.org
[http]: https://golang.org/pkg/net/http
[httptest]: https://golang.org/pkg/net/http/httptest/
[tabwriter]: https://golang.org/pkg/text/tabwriter/
