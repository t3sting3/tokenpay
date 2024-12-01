AC_INIT([tokenpayd], [2.0.0])
AC_CONFIG_SRCDIR([src/main.cpp])
AC_CONFIG_AUX_DIR([.])
AM_INIT_AUTOMAKE([foreign 1.13 subdir-objects -Wall -Werror -Wno-portability])
AC_CONFIG_MACRO_DIRS([m4])
AM_PROG_AS
AM_PROG_AR
AC_PROG_MKDIR_P
AC_PROG_CC
AC_PROG_CXX

dnl Handle mingw-specific libtool issues
case $host in
  *mingw*)
    lt_cv_deplibs_check_method="pass_all"
    lt_cv_prog_compiler_pic="-DPIC"
    lt_cv_prog_compiler_pic_CXX="-DPIC"
    ;;
  *darwin*)
    lt_cv_apple_cc_single_mod="yes"
    ;;
esac

AC_PROG_OBJCXX
LT_INIT
AC_CANONICAL_HOST

build_linux=no
build_windows=no
build_mac=no

case "${host_os}" in
  linux*)
    build_linux=yes
    ;;
  cygwin*|mingw*)
    build_windows=yes
    ;;
  darwin*)
    build_mac=yes
    ;;
  *)
    AC_MSG_ERROR(["OS $host_os is not supported"])
    ;;
esac

AM_CONDITIONAL([OS_LINUX], [test "$build_linux" = "yes"])
AM_CONDITIONAL([OS_WINDOWS_CROSSCOMPILE], [test "$build_windows" = "yes"])
AM_CONDITIONAL([OS_MACOS], [test "$build_mac" = "yes"])

AX_CXX_COMPILE_STDCXX(14, noext, mandatory)
AC_CONFIG_FILES([Makefile src/Makefile])
PKG_PROG_PKG_CONFIG

if test x$use_pkgconfig = xyes; then
  PKG_CHECK_MODULES(LIBEVENT, [libevent], [], [AC_MSG_ERROR([libevent not found])])
  PKG_CHECK_MODULES(ZLIB, [zlib], [], [AC_MSG_ERROR([zlib not found])])

  if test x$TARGET_OS = xlinux; then
    PKG_CHECK_MODULES(LIBSECCOMP, [libseccomp], [], [AC_MSG_ERROR([libseccomp not found])])
    PKG_CHECK_MODULES(LIBCAP, [libcap], [], [AC_MSG_ERROR([libcap not found])])
  fi

  PKG_CHECK_MODULES([SSL], [libssl],, [AC_MSG_ERROR(openssl not found.)])
  PKG_CHECK_MODULES([CRYPTO], [libcrypto],,[AC_MSG_ERROR(libcrypto not found.)])

  VERGE_QT_CHECK([PKG_CHECK_MODULES([PROTOBUF], [protobuf], [have_protobuf=yes], [VERGE_QT_FAIL(libprotobuf not found)])])

  if test x$use_qr != xno; then
    VERGE_QT_CHECK([PKG_CHECK_MODULES([QR], [libqrencode], [have_qrencode=yes], [have_qrencode=no])])
  fi

  if test x$build_verge_utils$BUILD_VERGEd$verge_enable_qt$use_tests != xnononono; then
    PKG_CHECK_MODULES([EVENT], [libevent],, [AC_MSG_ERROR(libevent not found.)])
    if test x$TARGET_OS != xwindows; then
      PKG_CHECK_MODULES([EVENT_PTHREADS], [libevent_pthreads],, [AC_MSG_ERROR(libevent_pthreads not found.)])
    fi
  fi

  if test "x$use_zmq" = "xyes"; then
    PKG_CHECK_MODULES([ZMQ], [libzmq >= 4],
      [AC_DEFINE([ENABLE_ZMQ], [1], [Define to 1 to enable ZMQ functions])],
      [AC_DEFINE([ENABLE_ZMQ], [0], [Define to 1 to enable ZMQ functions])
       AC_MSG_WARN([libzmq version 4.x or greater not found, disabling])
       use_zmq=no])
  else
    AC_DEFINE_UNQUOTED([ENABLE_ZMQ], [0], [Define to 1 to enable ZMQ functions])
  fi
else
  AC_CHECK_HEADER([openssl/crypto.h],,AC_MSG_ERROR(libcrypto headers missing))
  AC_CHECK_LIB([crypto], [main], CRYPTO_LIBS=-lcrypto, AC_MSG_ERROR(libcrypto missing))

  AC_CHECK_HEADER([openssl/ssl.h],, AC_MSG_ERROR(libssl headers missing))
  AC_CHECK_LIB([ssl], [main], SSL_LIBS=-lssl, AC_MSG_ERROR(libssl missing))

  if test x$build_verge_utils$BUILD_VERGEd$verge_enable_qt$use_tests != xnononono; then
    AC_CHECK_HEADER([event2/event.h],, AC_MSG_ERROR(libevent headers missing))
    AC_CHECK_LIB([event], [main], EVENT_LIBS=-levent, AC_MSG_ERROR(libevent missing))
    if test x$TARGET_OS != xwindows; then
      AC_CHECK_LIB([event_pthreads], [main], EVENT_PTHREADS_LIBS=-levent_pthreads, AC_MSG_ERROR(libevent_pthreads missing))
    fi
  fi
fi

BOOST_REQUIRE([1.58])
BOOST_SYSTEM([mt])
BOOST_CHRONO([mt])
BOOST_FILESYSTEM([mt])
BOOST_PROGRAM_OPTIONS([mt])
BOOST_THREAD([mt])
BOOST_ASIO
BOOST_DATE_TIME([mt])
BOOST_IOSTREAMS([mt])

MACOS_RPATH=""
AC_ARG_ENABLE([gui], [AS_HELP_STRING([--enable-gui], [Build the Qt GUI wallet])])

if test "x$enable_gui" = "xyes"; then
  AC_ARG_WITH([qt5], [AS_HELP_STRING([--with-qt5], [Manually specify the path to a stand-alone Qt5 installation])], [
    ...
  ])
fi

AM_CONDITIONAL([ENABLE_GUI], [test "$enable_gui" = "yes"])

AX_SUBDIRS_CONFIGURE([src/secp256k1], [[--disable-shared], [--with-pic], [--with-bignum=no], [--enable-module-recovery]])
AX_SUBDIRS_CONFIGURE([tor], [[--disable-unittests], [--disable-systemd]])

AC_OUTPUT
