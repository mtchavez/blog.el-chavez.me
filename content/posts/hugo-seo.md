---
categories:
- hugo
- seo
keywords:
- hugo
- hugo seo
- seo
tags:
- hugo
- hugo seo
- seo
series:
- hugo
- seo
comments: true
date: '2015-11-26'
title: Go Hugo SEO
description: Some simple things to do with Hugo for SEO and dynamic page content
url: /2015/11/26/go-hugo-seo
---

[Hugo](http://gohugo.io) is a static site generator that has caught on for its
simplicity and the fact it is built in [Go](https://golang.org/). You can run
it as a server or build the static site to host somewhere. If you are using
Hugo to build a full site or just a blog you will most likely want to have some
dynamic page setup for SEO or analytics. Luckily this is easy enough to do
with Hugo.
<!--more-->

## Page Keywords

Whether you have blog posts or your main site generated with Hugo you will want
to set `keywords` per page. This will allow you to set your dynamic `meta`
keyword tags for content. An example in markdown would be to add keywords
to your page metadata:

```yaml
---
keywords:
- mysite
- mysite keyword
- Another useful keyword
title: My Homepage
---
```

With this added per page we can now add the `meta` tag for our keywords so that
we have dynamic keywords per content page. In order to do that we will use a
templating function to achieve this. In a `header` partial template or your
default tamplate add the meta tag to your `<head>`

```go
<meta content="{{ delimit .Keywords ", " }}" name="keywords">
```

## Page Title

Applying the page title by page is relatively easy and is in most themes and
examples. You may want to include your site name with the page title or the
theme you are using or have created may not have this set up yet. To do this
you can do a relatively simple check for the homepage and title to correctly
display. Again add this to wherever youd `<head>` tag gets generated

```go
<title>{{ $isHomePage := eq .Title .Site.Title }}{{ .Title }}{{ if eq $isHomePage false }} - {{ .Site.Title }}{{ end }}</title>
```

In addition to the page title you will want to add a `meta` tag for the title
as well

```go
<meta content="{{ $isHomePage := eq .Title .Site.Title }}{{ .Title }}{{ if eq $isHomePage false }} - {{ .Site.Title }}{{ end }}" property="og:title">
```

## Page Description

One other useful dynamic page setting we can utilize is to add a per page
description as well as using your site description. To set the site description
you do this in your hugo `config.toml`, or `config.yaml`. Set this in the
`params` section to be able to use in your templates.

```toml
[params]
description = "Site stuff for being a good site with internet tubez."
```

In addition to a site description we can use a per page description by adding
a `description` field

```yaml
---
keywords:
  - mysite
  - mysite keyword
  - Another useful keyword
title: My Homepage
description: Where you should come to find my homepage updates and stuff
---
```

Now we can follow the same pattern as before with our page title and set the
page description, if available, with our site description. Again in the `head`
section we will add another meta tag

```go
<meta content="{{ $isHomePage := eq .Title .Site.Title }}{{ .Site.Params.description }}{{ if eq $isHomePage false }} - {{ .Description }}{{ end }}" property="og:description">
```

---

With a few custom settings and meta fields per page we can easily utilize them
to build more dynamic page content. Whether you are building a blog or doing
your whole site with Hugo you can still keep your SEO in mind.
