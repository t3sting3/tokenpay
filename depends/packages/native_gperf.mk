package=native_gperf
$(package)_version=3.1
$(package)_download_path=https://ftp.gnu.org/pub/gnu/gperf/
$(package)_file_name=gperf-$($(package)_version).tar.gz
$(package)_sha256_hash=588546B945BBA4B70B6A3A616E80B4AB466E3F33024A352FC2198112CDBB3AE2

define $(package)_set_vars
  $(package)_config_opts=--disable-manpages
endef

define $(package)_config_cmds
  $($(package)_autoconf)
endef

define $(package)_build_cmd
  $(MAKE)
endef

define $(package)_stage_cmds
  $(MAKE) DESTDIR=$($(package)_staging_dir) install
endef