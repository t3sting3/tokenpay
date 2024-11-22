packages:=boost openssl libevent zeromq libseccomp libcap
native_packages := native_ccache

qt_native_packages = native_protobuf native_gperf
qt_packages = qrencode protobuf zlib icu sqlite3

qt_x86_64_linux_packages:=qt expat dbus libxcb xcb_proto libXau xorgproto xproto freetype fontconfig libX11 xextproto libXext xtrans libXrender renderproto native_gperf
qt_i686_linux_packages:=$(qt_x86_64_linux_packages)

qt_darwin_packages=qt
qt_mingw32_packages=qt

wallet_packages=bdb

upnp_packages=miniupnpc

darwin_native_packages = native_biplist native_ds_store native_mac_alias

ifneq ($(build_os),darwin)
darwin_native_packages += native_cctools native_cdrkit native_libdmg-hfsplus
endif
