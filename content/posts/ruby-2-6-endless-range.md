---
categories:
- ruby
- til
- programming languages
keywords:
- ruby
- ruby 2.6
- endless range ruby 2.6
- cannot get the last element of endless range
tags:
- ruby
- til
- programming languages
comments: true
date: '2019-03-08'
title: Ruby 2.6 Endless Range
description: Endless ranges in ruby 2.6 and how to update your previous ruby code to use them.
url: /2019/03/08/ruby-2-6-endless-range
---
For a _today I learned_ moment I ran into the new endless range feature in ruby
2.6 by coming across some code that triggered this error message:

```
RangeError (cannot get the last element of endless range)
```

The code that was updated to the latest ruby 2.6 release had a dynamic range
that was pulling fields from a database and doing something like this:
<!--more-->

```ruby
post = Post.where(commentable: true)
post_range = post.minimum(:year)..post.maximum(:year)
```

The culprit to expose this was that the above rails code will return a `nil` for
the min/max calculation queries if there isn't a value so we end up with

```ruby
post_range = nil..nil
```

Which is a valid statement in ruby 2.6 as a Range with endless functionality.

## Ranges in Ruby before 2.6

Before the ruby 2.6 release if we tried to use nil in ranges we would see something
like this:

```ruby
range = nil..nil # valid range nil..nil
range.size # returns nil
range.last # returns nil
```

As you can see we are able to handle the same nil range if it is a nil from start
to end. Everthing about the range returns `nil` though so this sort of hides the
fact that you have a range that doesn't make much sense.

Lets try the same thing but with a number to start with a nil terminating value

```ruby
range = 1..nil
# ArgumentError (bad value for range)
```

We get an `ArgumentError`. This makes sense in the pre ruby 2.6 world as going from
1 to a `nil` doesn't have any implied range of values to expand to.

## Ranges as of 2.6

For the above examples we can look at the same code but in ruby 2.6 and see what
has changed. Here is the nil to nil range:

```ruby
range = nil..nil
range.size # returns nil
range.last
# RangeError (cannot get the last element of endless range)
```

Here we see that the range of `nil..nil` is different and when looking for the
last element we are getting a `RangeError` due to it being an _endless range_
as it has a `nil` terminating value for the range.

One weird thing to note is that the size here is still returning a `nil` value.
Since the range is not starting out at anything this may be the reason for it
knowing there is not a size of `Infinity`. Oddly enough in ruby 2.6 this is still
being called an _endless range_.

Next we can look at the range with a starting numeric value.

```ruby
range = 1..nil # 1..nil
range.size # Infinity
range.last
# RangeError (cannot get the last element of endless range)
```

Slightly different, we see that the range has a _known size_ of `Inifnity`. This
is convenient to check if the range itself is endless before doing something like
the trying to get the last element. If you notice endless ranges will be throwing
`RangeError` exceptions if you are trying to get the last element. Other methods
also show that the `RangeError` will happen if you are trying to do calculations
that require knowing the end element

```ruby
range.first # returns the first element which is known to be 1
range.min   # returns 1 as this is known
range.max   # Throws RangeError since it can't be determined
range.last  # Throws RangeError since it isn't known
range.end   # returns nil
```

## Working with ruby 2.6 endless ranges

With endless ranges now a part of the language you may have some old code you
never knew, or cared, that has `nil..nil` endless ranges defined. So what can
you do to handle them.

* If you want to verify there could be an endless range you can look at the last
  element to see if it is there or not.

  ```ruby
  post_range = min..max
  if post_range.end
    # do something with range
  else
    # handle endless range case
  end
  ```

* If there is a dynamic max being used with numeric values you can check the end
  value, like before, or verify the max is a member of the range itself

  ```ruby
  post_range = 1970..max
  if post_range.member?(max)
    # The max value is a member of the range
    # if the max is nil it won't be a member of the range of 1970 to Infinity
  else
    # handle the endless range case
  end
  ```

* With the `#member?` method you have to be careful if the range is `nil..nil`
  because it will not be able to iterate from the starting `nil` to determine
  the range and will raise `TypeError (can't iterate from NilClass)`

* Perhaps we want to know the range is endless. We might want to look at extending
  the `Range` class to have that ability.

  ```ruby
  class Range
    # endless? determines if the range ends or if it has no end present. If one
    # is not present it will return true
    #
    # @return [Boolean] Whether the range has an end or not
    def endless?
      self.end ? false : true
    end
  end

  post_range = 1970..nil
  return if post_range.endless?
  # Continue knowing the range has an end
  ```

* Or one step further we could be fine with knowing an endless range has a max
  and last value of `Infinity` to avoid any errors raised if we check those values
  for an endless range

  ```ruby
  class Range
    # endless? determines if the range ends or if it has no end present. If one
    # is not present it will return true
    #
    # @return [Boolean] Whether the range has an end or not
    def endless?
      self.end ? false : true
    end

    alias original_max max

    # max value of the range
    #
    # @return [Object|Float::INFINITY] The max of the range or Float::INFINITY
    #         if the range is endless
    def max
      endless? ? Float::INFINITY : original_max
    end

    alias original_last last
    # last value of the range
    #
    # @return [Object|Float::INFINITY] The last object of the range or Float::INFINITY
    #         if the range is endless
    def last
      endless? ? Float::INFINITY : original_last
    end
  end

  post_range = 1970..nil
  post_range.endless? # true
  post_range.max # Infinity
  post_range.last # Infinity
  ```

These are just some of the things you can now do with ranges starting in ruby 2.6.
Knowing that a `nil` as an end value for a range turns it into an endless range is
where you have to begin checking your code where this can happen to handle the possibility
of an endless range. _Note that the example with overriding the max and last methods
of range is an example and it might not be desired to actually do this_. Ranges
in ruby can take any object that implements `Comparable` so you could have some
weirdness always returning `Infinity`. That being said if it is truly an endless range
that does tell us that it has no finite end or max value.

---

Some links to check out

- [Ruby 2.6 release notes][2-6-release]
- [Ruby Range docs][range]

[2-6-release]: https://ruby-doc.org/core-2.6.1/Range.html
[range]: https://ruby-doc.org/core-2.6.1/Range.html
