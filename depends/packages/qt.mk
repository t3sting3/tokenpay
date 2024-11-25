# Qt Configuration
PACKAGE=qt
$(package)_version=5.7.1
$(package)_download_path=http://download.qt.io/official_releases/qt/5.7/$($(package)_version)/submodules
$(package)_suffix=opensource-src-$($(package)_version).tar.gz
$(package)_file_name=qtbase-$($(package)_suffix)
$(package)_sha256_hash=95f83e532d23b3ddbde7973f380ecae1bac13230340557276f75f2e37984e410
$(package)_dependencies=zlib icu native_gperf
$(package)_linux_dependencies=freetype fontconfig libxcb libX11 xproto libXext libXrender renderproto
$(package)_build_subdir=qtbase
$(package)_qt_libs=corelib network widgets gui plugins testlib sql concurrent printsupport

# Patches
$(package)_patches = mac-qmake.conf
$(package)_patches += mingw-uuidof.patch
$(package)_patches += pidlist_absolute.patch
$(package)_patches += fix-xcb-include-order.patch
$(package)_patches += 0007-Include-intrin.h-for-declaration-of-_mm_mfence.patch
$(package)_patches += strip_log2f.patch
$(package)_patches += fix_qt_pkgconfig.patch
$(package)_patches += fix-cocoahelpers-macos.patch
$(package)_patches += qfixed-coretext.patch
$(package)_patches += fix_mojave_fonts.patch
$(package)_patches += fix_qt_configure.patch

# Additional Sources
$(package)_qttranslations_file_name=qttranslations-$($(package)_suffix)
$(package)_qttranslations_sha256_hash=3a15aebd523c6d89fb97b2d3df866c94149653a26d27a00aac9b6d3020bc5a1d
$(package)_qttools_file_name=qttools-$($(package)_suffix)
$(package)_qttools_sha256_hash=22d67de915cb8cd93e16fdd38fa006224ad9170bd217c2be1e53045a8dd02f0f
$(package)_download_path_webkit=http://download.qt.io/community_releases/5.6/5.6.0
$(package)_qtwebkit_file_name=qtwebkit-opensource-src-5.6.0.tar.gz
$(package)_qtwebkit_sha256_hash=8b3411cca15ff8b83e38fdf9d2f9113b81413980026e80462e06c95c3dcea056

$(package)_extra_sources = $(package)_qttranslations_file_name
$(package)_extra_sources += $(package)_qttools_file_name
$(package)_extra_sources += $(package)_qtwebkit_file_name

# SSL Extras
$(package)_ssl_extras_mingw32 = -lwsock32 -lgdi32
$(package)_ssl_extras = $($(package)_ssl_extras_$(host_os))

# Configuration Options
$(package)_config_opts += -bindir $(build_prefix)/bin
$(package)_config_opts += -c++std c++11
$(package)_config_opts += -confirm-license
$(package)_config_opts += -qt-harfbuzz
$(package)_config_opts += -prefix $(host_prefix)
$(package)_config_opts += -no-pch
$(package)_config_opts += -no-opengl
$(package)_config_opts += -silent
$(package)_config_opts += -pkg-config

# Fetch Commands
define $(package)_fetch_cmds
$(call fetch_file,$(package),$($(package)_download_path),$($(package)_download_file),$($(package)_file_name),$($(package)_sha256_hash)) && \
$(call fetch_file,$(package),$($(package)_download_path),$($(package)_qttranslations_file_name),$($(package)_qttranslations_file_name),$($(package)_qttranslations_sha256_hash)) && \
$(call fetch_file,$(package),$($(package)_download_path),$($(package)_qttools_file_name),$($(package)_qttools_file_name),$($(package)_qttools_sha256_hash)) && \
$(call fetch_file,$(package),$($(package)_download_path_webkit),$($(package)_qtwebkit_file_name),$($(package)_qtwebkit_file_name),$($(package)_qtwebkit_sha256_hash))
endef

# Extract Commands
define $(package)_extract_cmds
mkdir -p qtbase qttranslations qttools qtwebkit && \
tar -xf $($(package)_source) -C qtbase --strip-components=1 && \
tar -xf $($(package)_source_dir)/$($(package)_qttranslations_file_name) -C qttranslations --strip-components=1 && \
tar -xf $($(package)_source_dir)/$($(package)_qttools_file_name) -C qttools --strip-components=1 && \
tar -xf $($(package)_source_dir)/$($(package)_qtwebkit_file_name) -C qtwebkit --strip-components=1
endef

# Preprocess Commands
define $(package)_preprocess_cmds
for patch in $($(package)_patches); do \
  patch -p1 < $($(package)_patch_dir)/$$patch; \
done && \
sed -i 's|LIBS_PRIVATE += -lz|LIBS_PRIVATE += `pkg-config zlib --libs`|' qtwebkit/Source/WebCore/DerivedSources.pri && \
echo "CONFIG += force_bootstrap" >> qtbase/mkspecs/qconfig.pri
endef

# Configuration Commands
define $(package)_config_cmds
cd qtbase && \
./configure $($(package)_config_opts) && \
cd ../qtwebkit && ../qtbase/bin/qmake WebKit.pro -o Makefile && \
cd ../qttranslations && ../qtbase/bin/qmake qttranslations.pro -o Makefile && \
cd ../qttools/src/linguist/lrelease/ && ../../../../qtbase/bin/qmake lrelease.pro -o Makefile && \
cd ../..
endef

# Build Commands
define $(package)_build_cmds
cd qtbase && $(MAKE) sub-src-clean && \
cd ../qtwebkit && $(MAKE) && \
cd ../qttranslations && $(MAKE) && \
cd ../qttools/src/linguist/lrelease && $(MAKE)
endef

# Stage Commands
define $(package)_stage_cmds
cd qtbase && $(MAKE) install INSTALL_ROOT=$($(package)_staging_dir) && \
cd ../qtwebkit && $(MAKE) install INSTALL_ROOT=$($(package)_staging_dir) && \
cd ../qttranslations && $(MAKE) install INSTALL_ROOT=$($(package)_staging_dir) && \
cd ../qttools/src/linguist/lrelease && $(MAKE) install INSTALL_ROOT=$($(package)_staging_dir)
endef
