HUGO_THEME?=hucore
S3_BUCKET?=my-bucket
AWS_DEFAULT_REGION?=us-west-2

all:
	hugo server --theme $(HUGO_THEME) --watch --buildDrafts true

release:
	hugo -d deploy --theme=$(HUGO_THEME) && \
		cd deploy && \
		aws s3 sync . s3://$(S3_BUCKET) --region $(AWS_DEFAULT_REGION) --delete

.PHONY: all release
