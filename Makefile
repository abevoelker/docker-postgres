PROJECT  ?= abevoelker/postgres
TAG      ?= pg_stat_statements

ifdef REGISTRY
  IMAGE=$(REGISTRY)/$(PROJECT):$(TAG)
else
  IMAGE=$(PROJECT):$(TAG)
endif

.PHONY: all
all:
	@echo "Available targets:"
	@echo "  * build - build a Docker image for $(IMAGE)"
	@echo "  * pull  - pull down previous docker builds of $(IMAGE)"
	@echo "  * push  - push $(IMAGE) to remote registry"
	@echo "  * test  - build and test $(IMAGE)"

.PHONY: build
build:
	docker build -t $(IMAGE) .

.PHONY: pull
pull:
	docker pull $(IMAGE) || true

.PHONY: push
push:
	docker push $(IMAGE)
