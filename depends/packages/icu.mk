package=icu
$(package)_version=58.1
$(package)_download_path=http://dev-www.libreoffice.org/src
$(package)_file_name=1901302aaff1c1633ef81862663d2917-icu4c-58_1-src.tgz
$(package)_sha256_hash=0eb46ba3746a9c2092c8ad347a29b1a1b4941144772d13a88667a7b11ea30309
$(package)_build_subdir=source

$(package)_patch_xlocale = sed -i 's|xlocale[.]h|locale.h|' i18n/digitlst.cpp
$(package)_reverse_patch_xlocale_linux = true
$(package)_reverse_patch_xlocale_mingw32 = true
$(package)_reverse_patch_xlocale_darwin = sed -i 's|locale[.]h|xlocale.h|' i18n/digitlst.cpp
$(package)_reverse_patch_xlocale =  $($(package)_reverse_patch_xlocale_$(host_os))

define $(package)_set_vars
$(package)_config_opts=
endef

define $(package)_config_cmds
  $($(package)_patch_xlocale) && \
  mkdir native && cd native && ../configure && make -j 10 && cd .. && \
  $($(package)_reverse_patch_xlocale) && \
  $($(package)_autoconf) --with-cross-build=$($(package)_build_dir)/native --enable-extras=no \
  --enable-strict=no -enable-shared=yes --enable-tests=no \
  --enable-samples=no --enable-dyload=no --enable-tools=no
endef

define $(package)_build_cmds
  sed -i.old 's|gCLocale = _create_locale(LC_ALL, "C");|gCLocale = NULL;|' i18n/digitlst.cpp && \
  sed -i.old "s|freelocale(gCLocale);||" i18n/digitlst.cpp && \
  $(MAKE)
endef

define $(package)_stage_cmds
  $(MAKE) DESTDIR=$($(package)_staging_dir) install
endef