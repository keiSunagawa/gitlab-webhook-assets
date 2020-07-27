VERSION = latest

.PHONY: all
all: docker/build docker/push
.PHONY: docker
docker/build:
	docker build -t keisunagawa/gitlab-webhook-assets:${VERSION} .
.PHONY: docker/push
docker/push:
	docker push keisunagawa/gitlab-webhook-assets:${VERSION}
