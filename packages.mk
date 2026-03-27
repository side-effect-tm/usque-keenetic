.ONESHELL:
.SILENT:

PKG_ROOT := out/$(BUILD_DIR)
PKG_TEMP := out/tmp
PKG_CONTROL_ROOT := $(PKG_ROOT)/control
PKG_DATA_ROOT := $(PKG_ROOT)/data
PKG_DATA_APP_ROOT := $(PKG_DATA_ROOT)$(ROOT_DIR)
PKG_DATA_SHARED := $(PKG_DATA_APP_ROOT)/tmp/usque-keenetic

_pkg-prepare:
	echo "Prepare..."
	rm -rf $(PKG_ROOT)/
	mkdir -p $(PKG_CONTROL_ROOT)
	mkdir -p $(PKG_DATA_APP_ROOT)

_pkg-cleanup:
	echo "Clean up..."


_pkg-header:
	echo "Package: usque-keenetic" > $(PKG_CONTROL_ROOT)/control
	echo "Version: $(VERSION)" >> $(PKG_CONTROL_ROOT)/control
	echo "Depends: busybox" >> $(PKG_CONTROL_ROOT)/control
	# echo "Conflicts: package-id" >> $(PKG_CONTROL_ROOT)/control
	echo "License: MIT" >> $(PKG_CONTROL_ROOT)/control
	echo "Section: net" >> $(PKG_CONTROL_ROOT)/control
	echo "URL: https://github.com/side-effect/usque-keenetic" >> $(PKG_CONTROL_ROOT)/control
	echo "Architecture: $(PKG_ARCH)" >> $(PKG_CONTROL_ROOT)/control
	echo "Description: USQUE service (Unofficial Cloudflare WARP tunnel with MASQUE)" >> $(PKG_CONTROL_ROOT)/control
	echo "" >> $(PKG_CONTROL_ROOT)/control


_pkg-download-usque: USQUE_ZIP := $(PKG_TEMP)/usque-$(USQUE_ARCH).zip
_pkg-download-usque: TARGET_DIR := $(PKG_DATA_SHARED)/$(TARGET_ARCH)
_pkg-download-usque:
	if [ -f $(USQUE_ZIP) ]; then
		echo "Using cached: $(USQUE_ZIP)";
	else
		url=$$(curl -s "https://api.github.com/repos/Diniboy1123/usque/releases/tags/v$(USQUE_VERSION)" | \
			grep 'browser_download_url' | grep -E "linux_$(USQUE_ARCH)\." | \
			cut -d '"' -f 4);
		#
		echo "Downloading: $$url"
		mkdir -p $$(dirname $(USQUE_ZIP))
		@curl -sSL $$url -o $(USQUE_ZIP)
	fi
	#
	echo "Unpacking $(USQUE_ZIP)"
	mkdir -p $(TARGET_DIR)
	@unzip -o $(USQUE_ZIP) -d $(TARGET_DIR) usque


_pkg-content: CONFIG_VERSION=$(grep -E '^CONFIG_VERSION=' etc/usque/usque.conf 2>/dev/null | grep -oE '[0-9]+$$')
_pkg-content:
	echo "Write control files"
	cp scripts/ipk/conffiles $(PKG_CONTROL_ROOT)/conffiles
	make _combine FILES="scripts/ipk/_shared scripts/ipk/preinst" OUTPUT=$(PKG_CONTROL_ROOT)/preinst
	sed -i -E "s#^CURRENT_VERSION=([0-9]+)#CURRENT_VERSION=$(CONFIG_VERSION)#" $(PKG_CONTROL_ROOT)/preinst
	make _combine FILES="scripts/ipk/_shared scripts/network scripts/ipk/postinst" OUTPUT=$(PKG_CONTROL_ROOT)/postinst
	make _combine FILES="scripts/ipk/_shared scripts/ipk/prerm" OUTPUT=$(PKG_CONTROL_ROOT)/prerm
	make _combine FILES="scripts/ipk/_shared scripts/ipk/postrm" OUTPUT=$(PKG_CONTROL_ROOT)/postrm
	#
	echo "Write data files"
	cp -r fs/* $(PKG_DATA_APP_ROOT)/
	mkdir -p $(PKG_DATA_APP_ROOT)/var/log
	mkdir -p $(PKG_DATA_APP_ROOT)/var/run
	mkdir -p $(PKG_DATA_APP_ROOT)/etc/init.d
	#
	echo "Write init.d script"
	make _combine \
		FILES=" \
			scripts/init.d/entware-head \
			scripts/network \
			scripts/usque \
			scripts/init.d/_shared \
			scripts/init.d/entware-tail" \
		OUTPUT=$(PKG_DATA_APP_ROOT)/etc/init.d/S51usque
	chmod +x $(PKG_DATA_APP_ROOT)/etc/init.d/S51usque

_combine:
	mkdir -p $$(dirname $(OUTPUT))
	awk 'FNR==1 && NR!=1 {next} {print}' $(FILES) > $(OUTPUT)

_pkg-pack:
	cd $(PKG_CONTROL_ROOT)/; tar czvf ../control.tar.gz .; cd -
	cd $(PKG_DATA_ROOT)/; tar czvf ../data.tar.gz .; cd -
	# ipk
	echo 2.0 > $(PKG_ROOT)/debian-binary
	cd $(PKG_ROOT); tar czvf ../tmp/$(FILENAME) control.tar.gz data.tar.gz debian-binary; cd -


_pkg-build-mipsel:
	echo "Build mipsel package..."
	make _pkg-header
	make USQUE_ARCH=mipsle TARGET_ARCH=mipsel _pkg-download-usque

_pkg-build-mips:
	echo "Build mips package..."
	make _pkg-header
	make USQUE_ARCH=mips TARGET_ARCH=mips _pkg-download-usque

_pkg-build-aarch64:
	echo "Build aarch64 package..."
	make _pkg-header
	make USQUE_ARCH=arm64 TARGET_ARCH=aarch64 _pkg-download-usque


pkg-mipsel:
	make \
		BUILD_DIR=mipsel \
		PKG_ARCH=mipsel-3.4 \
		TARGET_ARCH=mipsel \
		USQUE_ARCH=mipsle \
		FILENAME=usque-keenetic_$(VERSION)_mipsel-3.4.ipk \
		_pkg-prepare _pkg-build-mipsel _pkg-content _pkg-pack _pkg-cleanup

pkg-mips:
	make \
		BUILD_DIR=mips \
		PKG_ARCH=mips-3.4 \
		TARGET_ARCH=mips \
		USQUE_ARCH=mips \
		FILENAME=usque-keenetic_$(VERSION)_mips-3.4.ipk \
		_pkg-prepare _pkg-build-mips _pkg-content _pkg-pack _pkg-cleanup

pkg-aarch64:
	make \
		BUILD_DIR=aarch64 \
		PKG_ARCH=aarch64-3.10 \
		TARGET_ARCH=mips \
		USQUE_ARCH=mips \
		FILENAME=usque-keenetic_$(VERSION)_aarch64-3.10.ipk \
		_pkg-prepare _pkg-build-aarch64 _pkg-content _pkg-pack _pkg-cleanup

pkg-multi:
	make \
		BUILD_DIR=all \
		PKG_ARCH=all \
		FILENAME=usque-keenetic_$(VERSION)_all_entware.ipk \
		_pkg-prepare _pkg-build-mipsel _pkg-build-mips _pkg-build-aarch64 \
		_pkg-pack _pkg-content _pkg-cleanup

pkg-all: pkg-mips pkg-mipsel pkg-aarch64 pkg-multi


pkg-dev:
	make \
		BUILD_DIR=aarch64 \
		PKG_ARCH=aarch64-3.10 \
		TARGET_ARCH=mips \
		USQUE_ARCH=mips \
		FILENAME=usque-keenetic_$(VERSION)_aarch64-3.10.ipk \
		_pkg-prepare _pkg-build-aarch64 _pkg-content _pkg-cleanup

