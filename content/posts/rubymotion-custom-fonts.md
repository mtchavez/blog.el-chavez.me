---
categories:
- rubymotion
- iOS
- mobile
keywords:
- rubymotion
- ruby
- iOS
- UIFont
- rubymotion fonts
- mobile
tags:
- rubymotion
- ruby
- iOS
- UIFont
- rubymotion fonts
- mobile
series:
- ruby
- iOS
- mobile
- rubymotion
comments: true
date: '2013-03-26'
title: Rubymotion Custom Fonts
description: How to use custom fonts in your Ruby Motion apps
url: /2013/03/26/rubymotion-custom-fonts
---

In your Rakefile add your font in the app setup.

<!--more-->

```ruby
Motion::Project::App.setup do |app|
  # App Settings
  app.fonts = ['st-marie.ttf']
end
```

Make sure your st-marie.ttf is in your resources directory


To use in your app do the following

```ruby
my_font = UIFont.fontWithName 'St Marie', size: 32
```

To find your font family name

```ruby
UIFont.familyNames.sort # Should contain 'St Marie'
```

To find the font names for a family name

```ruby
# Returns array of font names for 'St Marie'
UIFont.fontNamesForFamilyName 'St Marie'
```
