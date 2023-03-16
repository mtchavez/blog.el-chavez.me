---
categories:
- golang
- golang testing
- testing
- dependency injection
keywords:
- golang
- golang testing
- testing
- dependency injection
tags:
- golang
- testing
series:
- golang
- testing
comments: true
date: '2019-04-01'
title: Golang Testing time.Now
description: Testing time objects can be a pain. Do you freeze time, mock the current time, or swizzle the implementation? In golang lets look at using dependency injection to help test and drive your implementation.
url: /2019/04/01/golang-testing-time-now
---
Testing time objects can be a pain. Some languages offer some helpful libraries
that can help like [VCR][vcr] in Ruby. Other tools to help are mocking libraries
to where you can mock and stub out the time calls to what you want. In [golang][golang]
there is another way to help and that is using [dependency injection][di] to help make testing easier.
<!--more-->

Dependency injection is technique to cleanly manage dependencies of
an object or class. Rather than having the class be responsible for
creating its dependencies or delegate to another object to create them
it has them _injected_ into the object, usually through instantiation.

How this can help with testing comes along with the usage of interfaces
which inform how the injected dependencies can be used. To do that
we can use an interface in golang to construct a time provider

```go
package main

import (
	"fmt"
	"time"
)

type TimeProvider interface {
	Now() time.Time
}

type testTime struct {
	TimeProvider
}

func (t *testTime) Now() time.Time {
	now, _ := time.Parse(time.RFC3339, "2006-01-02T15:04:05Z")
	return now
}

func main() {
	t := &testTime{}
	fmt.Println(t.Now())
}
```

The time provider interface is defining a `Now()` function to conform to.
We will use this as a way to require any other time structs we
want to declare to know what _Now()_ means to it. For `testTime`
we implement _Now()_ to be `2006-01-02T15:04:05Z`. Clearly this
isn't very useful but it is the basis of how we can build to a world
with dependency injection of time provider structs to test our
own desired setup against expected outcomes.

One step further would be adding a second struct that implements
the _TimeProvider_ and has its own concept of what _Now()_ is.

```go
package main

import (
	"fmt"
	"time"
)

type TimeProvider interface {
	Now() time.Time
}

type testTime struct {
	TimeProvider
}

type anotherTime struct {
	TimeProvider
}

func (t *testTime) Now() time.Time {
	now, _ := time.Parse(time.RFC3339, "2006-01-02T15:04:05Z")
	return now
}

func (t *anotherTime) Now() time.Time {
	now, _ := time.Parse(time.RFC3339, "2010-12-25T15:04:05Z")
	return now
}

func main() {
	t := &testTime{}
	fmt.Println(t.Now())

	t2 := &anotherTime{}
	fmt.Println(t2.Now())
}
```

## Injecting A Time Provider

With our `TimeProvider` interface we can now make time structs for
whatever usecases we have. The next step we can take from there i to use our
interface as a way to inject any time structs that conform to our
provider. This helps us know that we always have a `Now()` function
to call as well as control the dependency's definition of `Now()`.

How that might look with a `Report` struct getting a time provider
as a dependency injected. For our report we want to make sure the
time provider injected in sets the created at of our report. As an
example the provider will set `Now()` as the beginning of the day.

```go
package main

import (
	"fmt"
	"time"
)

type TimeProvider interface {
	Now() time.Time
}

type Report struct {
	Name         string    `json:"name"`
	CreatedAt    time.Time `json:"created_at"`
	timeProvider TimeProvider
}

func NewReport(timeProvider TimeProvider, name string) *Report {
	return &Report{
		Name:         name,
		CreatedAt:    timeProvider.Now(),
		timeProvider: timeProvider,
	}
}

type ReportCreatedAtTime struct {
	TimeProvider
}

func (t *ReportCreatedAtTime) Now() time.Time {
	// Returns beginning of day
	now := time.Now()
	return now.Truncate(24 * time.Hour)
}

func main() {
	reportTimeProvider := &ReportCreatedAtTime{}
	report := NewReport(reportTimeProvider, "todays-report")

	fmt.Printf("Report %+v\n", report)
}
```

A `Report` is made up of the name of the report and a time it was
created at. We have also added a dependency on our `TimeProvider`
that can be passed into the `NewReport` function to create new
reports. The usecase we wanted to satisfy is to set the `CreatedAt`
to the beginning of today.

To achieve this the `ReportCreatedAtTime` implements the time provider
and defines `Now()` to return the beginning of today. This is used to
create a new report and all it has to know is it can call a `Now()`
function on the provider it is being _injected_ with.

The last step to this is to see how we can put this all together for
a testing the report created at functionality.

## Testing With The Time Provider

Now that we can inject time providers into a report the testing of our report
can be pretty simple. As long as we have a provider that conforms
to the `TimeProvider` interface we can inject our test setup with
whatever conditions we want to test. _Meaning we can test time_ in
our code with little friction.

```go
package main

import (
	"fmt"
	"testing"
	"time"
)
//
// same implementation as above but left out for brevity
//

//
// Tests
//

type testReportCreatedAtTime struct {
	TimeProvider
}

func (t *testReportCreatedAtTime) Now() time.Time {
	testTime, _ := time.Parse(time.RFC3339, "2006-01-02T15:04:05Z")
	return testTime
}

func TestNewReport(t *testing.T) {
	testCreatedAtTime := &testReportCreatedAtTime{}
	testReport := NewReport(testCreatedAtTime, "test-report")
	if testReport.CreatedAt != testCreatedAtTime.Now() {
		t.Errorf("Expected report CreatedAt to be %s but got %s", testCreatedAtTime.Now(), testReport.CreatedAt)
	}
}
```

In our tests we create our own test time provider `testReportCreatedAtTime` to use
in our setup. Since we are conforming to the `TimeProvider` interface we need to
define a `Now()` function to use in our test provider as well. Which we just parse
an arbitrary date and time. Creating our time provider and passing it into our `NewReport`
function for a test report allows us to know exactly what our `CreatedAt` time should
be for our report.

We didn't mock or stup anything out in this setup. The imports are all just standard
library packages and our reporter knows nothing about time except for the fact
it takes in a time provider that responds to a `Now()` function.

## Wrapping Up

The implementation we arrived at using dependency injection to test time in our
golang code is easy to follow and concise. The test setup requires no extra libraries.
We aren't mocking or stubbing out any implementation of time or the time package
itself so we are using real time objects. One downside may be the amount of setup
for the tests themselves could be large for interfaces that require more method signatures
to implement.

Overall I have found this approach to be pretty convenient and allows for easier management
of time dependencies in your codebase.

[di]: https://en.wikipedia.org/wiki/Dependency_injection
[golang]: https://golang.org
[vcr]: https://github.com/vcr/vcr/
