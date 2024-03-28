# - init general vars
BUILD_DIR = build
export BUILD_DIR
RESULTS_DIR = results
export RESULTS_DIR
VERSION = $(shell bash -c 'source version; echo $$VERSION')
export VERSION

DOCKER_REGISTRY ?= local
DOCKER_TAG ?= latest

# - init go vars
GOPRIVATE = *.f5net.com,gitlab.com/f5
export GOPRIVATE

.PHONY: default tools deps fmt lint test build build.docker publish

default: build

tools:
	@go install gotest.tools/gotestsum@latest
	@go install golang.org/x/tools/cmd/goimports@latest
	@go install github.com/jstemmer/go-junit-report@v1.0.0
	@curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $$(go env GOPATH)/bin v1.57.1

deps:
	@go mod download
	@go mod tidy
	@go mod verify

fmt:
	@find . -type f -name "*.go" -exec goimports -e -w {} \+

lint:
	@find . -type f -name "*.go" -exec goimports -e -w {} \+
	@golangci-lint run -v ./...

test:
	@./scripts/test.sh

build:
	@./scripts/build.sh

build-linux:
	@./scripts/build.sh linux

build-linux-docker:
	@./scripts/docker.sh build

publish: build-linux build-linux-docker
	@scripts/docker-login.sh
	@./scripts/docker.sh publish

clean:
	rm -rf $(BUILD_DIR)/
