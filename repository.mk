.ONESHELL:
.SILENT:

REPO_ROOT := out/_pages/$(BUILD_DIR)

_repo-clean:
	rm -rf $(REPO_ROOT)/
	mkdir -p $(REPO_ROOT)

_repo-copy:
	cp out/tmp/$(FILENAME) $(REPO_ROOT)/

_repo-html:
	echo '<html><head><title>usque-keenetic repository</title></head><body>' > $(REPO_ROOT)/index.html
	echo '<h1>Index of /$(BUILD_DIR)/</h1><hr>' >> $(REPO_ROOT)/index.html
	echo '<pre>' >> $(REPO_ROOT)/index.html
	echo '<a href="../">../</a>' >> $(REPO_ROOT)/index.html
	echo '<a href="Packages">Packages</a>' >> $(REPO_ROOT)/index.html
	echo '<a href="Packages.gz">Packages.gz</a>' >> $(REPO_ROOT)/index.html
	echo '<a href="$(FILENAME)">$(FILENAME)</a>' >> $(REPO_ROOT)/index.html
	echo '</pre>' >> $(REPO_ROOT)/index.html
	echo '<hr></body></html>' >> $(REPO_ROOT)/index.html

_repo-index:
	echo '<html><head><title>usque-keenetic repository</title></head><body>' > out/_pages/index.html
	echo '<h1>Index of /</h1><hr>' >> out/_pages/index.html
	echo '<pre>' >> out/_pages/index.html
	echo '<a href="all/">all/</a>' >> out/_pages/index.html
	echo '<a href="aarch64/">aarch64/</a>' >> out/_pages/index.html
	echo '<a href="mips/">mips/</a>' >> out/_pages/index.html
	echo '<a href="mipsel/">mipsel/</a>' >> out/_pages/index.html
	echo '</pre>' >> out/_pages/index.html
	echo '<hr></body></html>' >> out/_pages/index.html

_repository:
	make _repo-clean
	make _repo-copy
	#
	echo "Package: usque-keenetic" > $(REPO_ROOT)/Packages
	echo "Version: $(VERSION)" >> $(REPO_ROOT)/Packages
	echo "Depends: busybox" >> $(REPO_ROOT)/Packages
	echo "Section: net" >> $(REPO_ROOT)/Packages
	echo "Architecture: $(ARCH)" >> $(REPO_ROOT)/Packages
	echo "Filename: $(FILENAME)" >> $(REPO_ROOT)/Packages
	echo "Size: $(shell wc -c out/tmp/$(FILENAME) | awk '{print $$1}')" >> $(REPO_ROOT)/Packages
	echo "SHA256sum: $(shell sha256sum out/tmp/$(FILENAME) | awk '{print $$1}')" >> $(REPO_ROOT)/Packages
	echo "Description:  USQUE service" >> $(REPO_ROOT)/Packages
	echo "" >> $(REPO_ROOT)/Packages
	#
	gzip -k $(REPO_ROOT)/Packages
	make _repo-html

repo-mipsel:
	@make \
		BUILD_DIR=mipsel \
		ARCH=mipsel-3.4 \
		FILENAME=usque-keenetic_$(VERSION)_mipsel-3.4.ipk \
		_repository

repo-mips:
	@make \
		BUILD_DIR=mips \
		ARCH=mips-3.4 \
		FILENAME=usque-keenetic_$(VERSION)_mips-3.4.ipk \
		_repository

repo-aarch64:
	@make \
		BUILD_DIR=aarch64 \
		ARCH=aarch64-3.10 \
		FILENAME=usque-keenetic_$(VERSION)_aarch64-3.10.ipk \
		_repository

repo-multi:
	@make \
		BUILD_DIR=all \
		ARCH=all \
		FILENAME=usque-keenetic_$(VERSION)_all_entware.ipk \
		_repository

repository: repo-mipsel repo-mips repo-aarch64 repo-multi _repo-index
