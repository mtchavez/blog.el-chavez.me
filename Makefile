HUGO_THEME?=ananke
S3_BUCKET?=blog.el-chavez.me
AWS_DEFAULT_REGION?=us-west-2

all:
	hugo server --theme $(HUGO_THEME) -D --watch --buildDrafts true

build:
    HUGO_ENV=production hugo --gc --theme $(HUGO_THEME) -e production -v

release: build
    HUGO_ENV=production hugo deploy -e production -v

.PHONY: all build release
