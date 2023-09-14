DESTDIR ?=
prefix ?= /usr
MODULES_DIR = $(DESTDIR)$(prefix)/share/mender/modules/v3
SUB_MODULES_DIR = $(DESTDIR)$(prefix)/share/mender/app-modules/v1
MODULES = src/app
SUB_MODULES = src/app-modules/docker-compose src/app-modules/k8s

install:
	@install -d -m 755 $(MODULES_DIR)
	@install -d -m 755 $(SUB_MODULES_DIR)
	for m in $(MODULES); do install -m 755 $$m $(MODULES_DIR)/; done
	for m in $(SUB_MODULES); do install -m 755 $$m $(SUB_MODULES_DIR)/;	done
