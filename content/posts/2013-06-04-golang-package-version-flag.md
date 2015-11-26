---
categories:
- go
- golang
keywords:
- go
- golang
- golang flag
- golang versioning
comments: true
date: '2013-06-04'
title: Golang Package Version Flag
description: How to implement a version flag for golang packages
url: /2013/06/04/golang-package-version-flag
---


So you’ve built your first service using Go and have it deployed out into your
production environment. With cross compiling built into Go it’s easy and almost
trivial to build a new binary of your code and deploy updates. But what happens
when you need to know what version of your code is where or how can you easily
verify your new binary was deployed.

There is a built in library in Go that handles flag parsing, the flag package.
Using the flag package is straight forward and allows us to use flags to pass
to our binary to print a version out.

First lets start with a main package that imports the flag package.
<!--more-->

{{<highlight go>}}
package main

import (
    "flag"
    "fmt"
)

func main() {
    flag.Parse()
    fmt.Println("Hello from main()")
}
{{</highlight>}}

If you have the file in your $GOROOT as main.go then run `go build main.go`
and after running `./main` you should see:

```
$ ./main
Hello from main()
```

So what did the `flag.Parse()` line do for us? Well it actually looked to
parse any flags passed to the program. Since we did not pass anything it does
not have to do any work here. Now lets add a version flag to parse so we can
print the version of our program.

{{<highlight go>}}
package main

import (
    "flag"
    "fmt"
    "os"
)

const AppVersion = "1.0.0 beta"

func main() {
    version := flag.Bool("v", false, "prints current app version")
    flag.Parse()
    if *version {
      fmt.Println(AppVersion)
      os.Exit(0)
    }
    fmt.Println("Hello from main()")
}
{{</highlight>}}

We first start by adding a definition of our version flag. It will be a boolean
flag with a name of v, a default of false and a description of what our flag means.
Next we call `flag.Parse()` to look for any flags passed into our program.
After parsing our version variable will have a value if we passed a `-v` to our
program when running it. Run your program again, this time passing in our `-v`
flag, and you should see the version string printed out and the program exist.

Some things to try out:

1. What happens if you don’t pass in the `-v` flag?
* What is the difference if you change the default value for the flag from false to true?
* If you pass a flag other than `-v` what is the output of the program?
