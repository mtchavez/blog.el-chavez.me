---
categories:
- rubymotion
- iOS
keywords:
- rubymotion
- ruby
- iOS
- UIFont
- rubymotion fonts
comments: true
date: '2013-03-26'
title: Rubymotion Custom Fonts
description: How to use custom fonts in your Ruby Motion apps
url: /2013/03/26/rubymotion-custom-fonts
---

In your Rakefile add your font in the app setup.

{{<highlight ruby>}}
Motion::Project::App.setup do |app|
  # App Settings
  app.fonts = ['st-marie.ttf']
end
{{</highlight>}}

Make sure your st-marie.ttf is in your resources directory


To use in your app do the following

{{<highlight ruby>}}
my_font = UIFont.fontWithName 'St Marie', size: 32
{{</highlight>}}

To find your font family name

{{<highlight ruby>}}
UIFont.familyNames.sort # Should contain 'St Marie'
{{</highlight>}}

To find the font names for a family name

{{<highlight ruby>}}
# Returns array of font names for 'St Marie'
UIFont.fontNamesForFamilyName 'St Marie'
{{</highlight>}}
