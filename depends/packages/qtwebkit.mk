PACKAGE=QTWEBKIT
$(package)_version=5.9.2
$(package)_download_path=https://download.qt.io/snapshots/ci/qtwebkit/5.9/1562081748/src/submodules/
$(package)_file_name=qtwebkit-everywhere-src-5.9.2.tar.xz
$(package)_dependencies= = qtbase qtxmlpatterns qtdeclarative qtmultimedia qtjsbackend
$(package)_linux_dependencies=freetype fontconfig libxcb libX11 xproto libXext


define QTWEBKIT_CONFIGURE_CMDS
	-[ -f $(@D)/Makefile ] && $(MAKE) -C $(@D) distclean
	#run qmake
	(cd $(@D) && $(HOST_DIR)/usr/bin/qmake )
endef

define QTWEBKIT_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D)
endef

define QTWEBKIT_INSTALL_STAGING_CMDS
	$(MAKE) -C $(@D) install
endef

define QTWEBKIT_INSTALL_TARGET_CMDS
	cp -dpf $(STAGING_DIR)/usr/lib/libQt5WebKit*.so.* $(TARGET_DIR)/usr/lib
	cp -dpf $(@D)/bin/* $(TARGET_DIR)/usr/bin/
	cp -dpfr $(STAGING_DIR)/usr/qml/QtWebKit $(TARGET_DIR)/usr/qml/
endef

define QTWEBKIT_UNINSTALL_TARGET_CMDS
	-rm $(TARGET_DIR)/usr/lib/libQt5Webkit*.so.*
endef

$(eval $(generic-package))