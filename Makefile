VERSION := $(shell cat VERSION)
USQUE_VERSION := $(shell cat USQUE_VERSION)
ROOT_DIR := /opt

include repository.mk
include packages.mk

.DEFAULT_GOAL := packages

clean:
	rm -rf out/
