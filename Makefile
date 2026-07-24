export RUBY_VERSION := $(shell cat .ruby-version)
export NODE_VERSION := $(shell cat .node-version)
export PLATFORM ?= linux/$(shell uname -m)

.PHONY: install build serve test docker-build docker-serve docker-up docker-down

install:
	bundle install
	npm ci

build:
	bundle exec rake dartsass:build

serve: build
	bundle exec rails server

test:
	bundle exec rails test

docker-build:
	docker-compose build

docker-build-amd64:
	PLATFORM=linux/amd64 docker-compose build

docker-serve:
	docker-compose up

docker-up:
	docker-compose up --build

docker-down:
	docker-compose down
