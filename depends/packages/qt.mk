PACKAGE=qt
$(PACKAGE)_version=5.9.8
$(PACKAGE)_download_path=https://download.qt.io/official_releases/qt/5.9/$(PACKAGE)_version/submodules
$(PACKAGE)_suffix=opensource-src-$(PACKAGE)_version.tar.xz
$(PACKAGE)_file_name=qtbase-$(PACKAGE)_suffix
$(PACKAGE)_sha256_hash=9b9dec1f67df1f94bce2955c5604de992d529dde72050239154c56352da0907d
$(PACKAGE)_dependencies=openssl zlib
$(PACKAGE)_linux_dependencies=freetype fontconfig libxcb libX11 xproto libXext
$(PACKAGE)_build_subdir=qtbase
$(PACKAGE)_qt_libs=corelib network widgets gui plugins testlib
$(PACKAGE)_patches=fix_qt_pkgconfig.patch mac-qmake.conf fix_configure_mac.patch fix_no_printer.patch fix_rcc_determinism.patch fix_riscv64_arch.patch xkb-default.patch

# QtTranslations
$(PACKAGE)_qttranslations_file_name=qttranslations-$(PACKAGE)_suffix
$(PACKAGE)_qttranslations_sha256_hash=fb5a47799754af73d3bf501fe513342cfe2fc37f64e80df5533f6110e804220c

# QtTools
$(PACKAGE)_qttools_file_name=qttools-$(PACKAGE)_suffix
$(PACKAGE)_qttools_sha256_hash=a97556eb7b2f30252cdd8a598c396cfce2b2f79d2bae883af6d3b26a2cdcc63c

# QtWebKit (different path)
$(PACKAGE)_qtwebkit_version=5.9.1
$(PACKAGE)_qtwebkit_download_path=https://github.com/qt/qtwebkit/releases/download/qtwebkit-$(PACKAGE)_qtwebkit_version
$(PACKAGE)_qtwebkit_file_name=qtwebkit-$(PACKAGE)_qtwebkit_version-src.tar.xz
$(PACKAGE)_qtwebkit_sha256_hash=0a979fb8bfe8aaad457500da319c04fe537dcdb4b5f9262a9ff0d84f226b47d7

# Add sources
$(PACKAGE)_extra_sources  = $(PACKAGE)_qttranslations_file_name
$(PACKAGE)_extra_sources += $(PACKAGE)_qttools_file_name
$(PACKAGE)_extra_sources += $(PACKAGE)_qtwebkit_file_name

define $(PACKAGE)_set_vars
$(PACKAGE)_config_opts_release = -release
$(PACKAGE)_config_opts_debug = -debug
$(PACKAGE)_config_opts += -bindir $(build_prefix)/bin
$(PACKAGE)_config_opts += -c++std c++11
$(PACKAGE)_config_opts += -confirm-license
$(PACKAGE)_config_opts += -dbus-runtime
$(PACKAGE)_config_opts += -hostprefix $(build_prefix)
$(PACKAGE)_config_opts += -no-compile-examples
$(PACKAGE)_config_opts += -no-cups
$(PACKAGE)_config_opts += -no-egl
$(PACKAGE)_config_opts += -no-eglfs
$(PACKAGE)_config_opts += -no-freetype
$(PACKAGE)_config_opts += -no-gif
$(PACKAGE)_config_opts += -no-glib
$(PACKAGE)_config_opts += -no-icu
$(PACKAGE)_config_opts += -no-iconv
$(PACKAGE)_config_opts += -no-kms
$(PACKAGE)_config_opts += -no-linuxfb
$(PACKAGE)_config_opts += -no-libudev
$(PACKAGE)_config_opts += -no-mtdev
$(PACKAGE)_config_opts += -no-openvg
$(PACKAGE)_config_opts += -no-reduce-relocations
$(PACKAGE)_config_opts += -no-qml-debug
$(PACKAGE)_config_opts += -no-sql-db2
$(PACKAGE)_config_opts += -no-sql-ibase
$(PACKAGE)_config_opts += -no-sql-oci
$(PACKAGE)_config_opts += -no-sql-tds
$(PACKAGE)_config_opts += -no-sql-mysql
$(PACKAGE)_config_opts += -no-sql-odbc
$(PACKAGE)_config_opts += -no-sql-psql
$(PACKAGE)_config_opts += -no-sql-sqlite
$(PACKAGE)_config_opts += -no-sql-sqlite2
$(PACKAGE)_config_opts += -no-use-gold-linker
$(PACKAGE)_config_opts += -no-xinput2
$(PACKAGE)_config_opts += -nomake examples
$(PACKAGE)_config_opts += -nomake tests
$(PACKAGE)_config_opts += -opensource
$(PACKAGE)_config_opts += -openssl-linked
$(PACKAGE)_config_opts += -optimized-qmake
$(PACKAGE)_config_opts += -pch
$(PACKAGE)_config_opts += -pkg-config
$(PACKAGE)_config_opts += -prefix $(host_prefix)
$(PACKAGE)_config_opts += -qt-libpng
$(PACKAGE)_config_opts += -qt-libjpeg
$(PACKAGE)_config_opts += -qt-pcre
$(PACKAGE)_config_opts += -qt-harfbuzz
$(PACKAGE)_config_opts += -system-zlib
$(PACKAGE)_config_opts += -static
$(PACKAGE)_config_opts += -silent
$(PACKAGE)_config_opts += -v
$(PACKAGE)_config_opts += -no-feature-dial
$(PACKAGE)_config_opts += -no-feature-ftp
$(PACKAGE)_config_opts += -no-feature-lcdnumber
$(PACKAGE)_config_opts += -no-feature-pdf
$(PACKAGE)_config_opts += -no-feature-printer
$(PACKAGE)_config_opts += -no-feature-printdialog
$(PACKAGE)_config_opts += -no-feature-concurrent
$(PACKAGE)_config_opts += -no-feature-sql
$(PACKAGE)_config_opts += -no-feature-statemachine
$(PACKAGE)_config_opts += -no-feature-syntaxhighlighter
$(PACKAGE)_config_opts += -no-feature-textbrowser
$(PACKAGE)_config_opts += -no-feature-textodfwriter
$(PACKAGE)_config_opts += -no-feature-udpsocket
$(PACKAGE)_config_opts += -no-feature-wizard
$(PACKAGE)_config_opts += -no-feature-xml
endef

# Fetch commands (now includes QtWebKit)
define $(PACKAGE)_fetch_cmds
$(call fetch_file,$(PACKAGE),$(PACKAGE)_download_path,$(PACKAGE)_file_name,$(PACKAGE)_file_name,$(PACKAGE)_sha256_hash) && \
$(call fetch_file,$(PACKAGE),$(PACKAGE)_download_path,$(PACKAGE)_qttranslations_file_name,$(PACKAGE)_qttranslations_file_name,$(PACKAGE)_qttranslations_sha256_hash) && \
$(call fetch_file,$(PACKAGE),$(PACKAGE)_download_path,$(PACKAGE)_qttools_file_name,$(PACKAGE)_qttools_file_name,$(PACKAGE)_qttools_sha256_hash) && \
$(call fetch_file,$(PACKAGE),$(PACKAGE)_qtwebkit_download_path,$(PACKAGE)_qtwebkit_file_name,$(PACKAGE)_qtwebkit_file_name,$(PACKAGE)_qtwebkit_sha256_hash)
endef

# Extract commands (now includes QtWebKit)
define $(PACKAGE)_extract_cmds
  mkdir -p $(PACKAGE)_extract_dir && \
  echo "$(PACKAGE)_sha256_hash  $(PACKAGE)_source" > $(PACKAGE)_extract_dir/.$(PACKAGE)_file_name.hash && \
  echo "$(PACKAGE)_qttranslations_sha256_hash  $(PACKAGE)_source_dir/$(PACKAGE)_qttranslations_file_name" >> $(PACKAGE)_extract_dir/.$(PACKAGE)_file_name.hash && \
  echo "$(PACKAGE)_qttools_sha256_hash  $(PACKAGE)_source_dir/$(PACKAGE)_qttools_file_name" >> $(PACKAGE)_extract_dir/.$(PACKAGE)_file_name.hash && \
  echo "$(PACKAGE)_qtwebkit_sha256_hash  $(PACKAGE)_source_dir/$(PACKAGE)_qtwebkit_file_name" >> $(PACKAGE)_extract_dir/.$(PACKAGE)_file_name.hash && \
  $(build_SHA256SUM) -c $(PACKAGE)_extract_dir/.$(PACKAGE)_file_name.hash && \
  mkdir qtbase && \
  tar --no-same-owner --strip-components=1 -xf $(PACKAGE)_source -C qtbase && \
  mkdir qttranslations && \
  tar --no-same-owner --strip-components=1 -xf $(PACKAGE)_source_dir/$(PACKAGE)_qttranslations_file_name -C qttranslations && \
  mkdir qttools && \
  tar --no-same-owner --strip-components=1 -xf $(PACKAGE)_source_dir/$(PACKAGE)_qttools_file_name -C qttools && \
  mkdir qtwebkit && \
  tar --no-same-owner --strip-components=1 -xf $(PACKAGE)_source_dir/$(PACKAGE)_qtwebkit_file_name -C qtwebkit
endef

# Build commands
define $(PACKAGE)_build_cmds
  $(MAKE) -C src $(addprefix sub-,$(PACKAGE)_qt_libs) && \
  $(MAKE) -C ../qttools/src/linguist/lrelease && \
  $(MAKE) -C ../qttools/src/linguist/lupdate && \
  $(MAKE) -C ../qttranslations && \
  $(MAKE) -C ../qtwebkit
