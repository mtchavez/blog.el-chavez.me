---
categories:
- til
- testing
- js
keywords:
- testing
- TIL
- momentjs
- jest
- javascript testing
tags:
- til
- testing
- js
series:
- til
- js
- testing
comments: true
date: '2019-03-14'
title: Momentjs Date Mutation
description: Using Momentjs in tests and dealing with the date mutation that happens for time shifting.
url: /2019/03/14/momentjs-tests-with-date-mutation
---
If you've ever had to work with a lot of date logic in javascript you've likely used or at
least seen [Momentjs][momentjs]. It can be convenient for moving dates to other timezones
or date math. I ran into another _today I learned_ moment trying to write some tests in
[Jest][jest] while using moment to handle dates in test setup and fixtures.
<!--more-->

I had a simplified version of some [Jest][jest] tests like this that were setting up some
user data with timestamps.

```javascript
import moment from 'moment';

describe('User', () => {
  describe('#report_for_yesterday', () => {
    const yesterdayPST = moment()
      .tz('America/Los_Angeles')
      .startOf('day')
      .subtract(1, 'days')
      .hour(10);
    const yesterdayDate = yesterdayPST.format('YYYY-MM-DD');

    it('returns users for yesterday', async () => {
      const users = [
        buildUser({
          timestamp: yesterdayPST.hour(0)
        }),
        buildUser({
          timestamp: yesterdayPST
        }),
        buildUser({
          timestamp: yesterdayPST
            .add(1, 'day')
            .hour(1)
        })
      ];
      const expectedUsers = [
        {
          created_date: yesterdayDate,
          // ... other user data
        }
      ];

      expect(User.report_for_yesterday()).toEqual(expectedUsers);
    });
  });
});
```

The issue here is when you have `yesterdayPST` being called in the test and setting
it to the beginning of the day it will _actually modify_ the `yesterdayPST` moment date
which will mess up the following uses of the date variable.

The way that moment allows you to deal with this is with the [Moment#clone][moment-clone]
function. This will allow you to make a copy of the expected date and do the mutations
on that date without affecting the original. The same test with the fixes would look
like this using `.clone()`

```javascript
import moment from 'moment';

describe('User', () => {
  describe('#report_for_yesterday', () => {
    const yesterdayPST = moment()
      .tz('America/Los_Angeles')
      .startOf('day')
      .subtract(1, 'days')
      .hour(10);
    const yesterdayDate = yesterdayPST.format('YYYY-MM-DD');

    it('returns users for yesterday', async () => {
      const users = [
        buildUser({
          timestamp: yesterdayPST.clone().hour(0)
        }),
        buildUser({
          timestamp: yesterdayPST
        }),
        buildUser({
          timestamp: yesterdayPST
            .clone()
            .add(1, 'day')
            .hour(1)
        })
      ];
      const expectedUsers = [
        {
          created_date: yesterdayDate,
          // ... other user data
        }
      ];

      expect(User.report_for_yesterday()).toEqual(expectedUsers);
    });
  });
});
```

The [Moment#clone][moment-clone] docs even have a call out that all moments are
mutable.

> All moments are mutable. If you want a clone of a moment, you can do so implicitly or explicitly.

So if you are writing tests and want to [DRY][dry] up some of your variables and setup
with dates don't forget to use `.clone()` where applicable for your [Moment][momentjs] date
objects.

[dry]: https://en.wikipedia.org/wiki/Don't_repeat_yourself
[jest]: https://jestjs.io/
[moment-clone]: https://momentjs.com/docs/#/parsing/moment-clone/
[momentjs]:https://momentjs.com/
