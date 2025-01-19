AC_INIT([tokenpayd],[2.0.1])
AC_CONFIG_SRCDIR([src/main.cpp])
AC_CONFIG_AUX_DIR([.])
AM_INIT_AUTOMAKE([foreign 1.13 subdir-objects -Wall -Werror -Wno-portability])
AC_CONFIG_MACRO_DIRS([m4])
AM_PROG_AS
AM_PROG_AR
AC_PROG_MKDIR_P
AC_PROG_CC
AC_PROG_CXX

dnl By default, libtool for mingw refuses to link static libs into a dll for
dnl fear of mixing pic/non-pic objects, and import/export complications. Since
dnl we have those under control, re-enable that functionality.
case $host in
  *mingw*)
     dnl By default, libtool for mingw refuses to link static libs into a dll for
     dnl fear of mixing pic/non-pic objects, and import/export complications. Since
     dnl we have those under control, re-enable that functionality.
     lt_cv_deplibs_check_method="pass_all"
	 
	 dnl Remove unwanted -DDLL_EXPORT from these variables.
     dnl We do not use this macro, but system headers may export unwanted symbols
     dnl if it's set.
     lt_cv_prog_compiler_pic="-DPIC"
     lt_cv_prog_compiler_pic_CXX="-DPIC"
  ;;
  *darwin*)
     dnl Because it prints a verbose warning, lld fails the following check
     dnl for "-Wl,-single_module" from libtool.m4:
     dnl   # If there is a non-empty error log, and "single_module"
     dnl   # appears in it, assume the flag caused a linker warning
     dnl "-single_module" works fine on ld64 and lld, so just bypass the test.
     dnl Failure to set this to "yes" causes libtool to use a very broken
     dnl link-line for shared libs.
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
PKG_CHECK_MODULES(OPENSSL, [openssl >= 1.0], [], [AC_MSG_ERROR([OpenSSL 1.1 not found])])
PKG_CHECK_MODULES(LIBEVENT, [libevent], [], [AC_MSG_ERROR([libevent not found])])
PKG_CHECK_MODULES(ZLIB, [zlib], [], [AC_MSG_ERROR([zlib not found])])
PKG_CHECK_MODULES(ZSTD, [libzstd], [], [AC_MSG_NOTICE([libzstd not found])])
PKG_CHECK_MODULES(LZMA, [liblzma], [], [AC_MSG_NOTICE([liblzma not found])])
AC_CHECK_LIB([snappy], [main], , [AC_MSG_NOTICE([snappy not found])])
AC_CHECK_LIB([pthread], [pthread_self], , [AC_MSG_ERROR([libpthread not found])])
AC_LANG([C++])

# TODO investigate whether earlier Boost versions will still work.
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

AC_ARG_WITH([openssl-dir],
  [AS_HELP_STRING([--with-openssl-dir=DIR], [Specify the directory where OpenSSL is installed])],
  [openssl_dir=$withval],
  [openssl_dir="/usr/local/ssl"])  # Default path
AC_SUBST([openssl_dir])

AC_ARG_ENABLE([gui], [AS_HELP_STRING([--enable-gui], [Build the Qt GUI wallet])])
if test "x$enable_gui" = "xyes" ; then
  AC_ARG_WITH([qt5], [AS_HELP_STRING([--with-qt5], [Manually specify the path to a stand-alone Qt5 installation (pkg-config will be used if not set). This has no effect if --enable-gui is not also specified.])], [
    if test "x$build_mac" = "xyes" ; then
      QT5_LIBDIR="$with_qt5/lib"
      MACOS_RPATH="-Wl,-rpath,$QT5_LIBDIR"
      QT5_LDFLAGS="-F$QT5_LIBDIR"
      QT5_CFLAGS="$QT5_LDFLAGS -I$QT5_LIBDIR/QtCore.framework/Headers -I$QT5_LIBDIR/QtGui.framework/Headers -I$QT5_LIBDIR/QtWidgets.framework/Headers -I$QT5_LIBDIR/QtNetwork.framework/Headers"
      QT5_LIBS="-framework QtCore -framework QtGui -framework QtWidgets -framework QtNetwork"
      MACDEPLOYQT="$with_qt5/bin/macdeployqt"
      AC_SUBST([MACDEPLOYQT])
    else
      QT5_CFLAGS="-I$with_qt5/include"
      QT5_LDFLAGS="-L$with_qt5/lib"
      QT5_LIBS="-lQt5Core -lQt5Gui -lQt5Widgets -lQt5Network"
    fi
    AC_SUBST([QT5_CFLAGS])
    AC_SUBST([QT5_LDFLAGS])
    AC_SUBST([QT5_LIBS])
    if test "x$build_windows" = "xyes"; then
    MOC="$with_qt5/native/bin/moc"
    UIC="$with_qt5/native/bin/uic"
    RCC="$with_qt5/native/bin/rcc"
    LRELEASE="$with_qt5/native/bin/lrelease"
    else
    MOC="$with_qt5/bin/moc"
    UIC="$with_qt5/bin/uic"
    RCC="$with_qt5/bin/rcc"
    LRELEASE="$with_qt5/bin/lrelease"
    fi
    AC_SUBST([MOC])
    AC_SUBST([UIC])
    AC_SUBST([RCC])
    AC_SUBST([LRELEASE])
    AC_MSG_NOTICE([Using Qt5 at $with_qt5])
  ], [
    PKG_CHECK_MODULES(QT5, [Qt5Core Qt5Gui Qt5Widgets Qt5Network], [AC_MSG_NOTICE([Found Qt5 using pkg-config.])], [
      PKG_CHECK_MODULES(QT5, [QtCore >= 5 QtGui >= 5 QtWidgets >= 5 QtNetwork >= 5], [AC_MSG_NOTICE([Found Qt >= 5 using pkg-config.])], [
        AC_MSG_ERROR([Qt5 not found.])
      ])
    ])
  ])
if test "x$enable_gui" = "xyes" ; then
    dnl Check for libdb_cxx only if wallet enabled
    TOKENPAY_FIND_BDB48
  fi
  if test "x$enable_gui" = "xno" ; then
    dnl Check for libdb_cxx only if wallet enabled
    TOKENPAY_FIND_BDB48
  fi
  MACDEPLOYQT_LIBPATH=""
  AC_ARG_WITH([qt5webkit], [AS_HELP_STRING([--with-qt5webkit], [Manually specify the path to a stand-alone Qt5WebKit installation (pkg-config will be used if not set). This has no effect if --enable-gui is not also specified.])], [
    if test "x$build_mac" = "xyes" ; then
      QT5WEBKIT_LIBDIR="$with_qt5webkit/lib"
      MACOS_RPATH="$MACOS_RPATH -Wl,-rpath,$QT5WEBKIT_LIBDIR"
      QT5WEBKIT_LDFLAGS="-F$QT5WEBKIT_LIBDIR"
      QT5WEBKIT_CFLAGS="$QT5WEBKIT_LDFLAGS -I$QT5WEBKIT_LIBDIR/QtWebKit.framework/Headers -I$QT5WEBKIT_LIBDIR/QtWebKitWidgets.framework/Headers"
      QT5WEBKIT_LIBS="-framework QtWebKit -framework QtWebKitWidgets"
      MACDEPLOYQT_LIBPATH="-libpath=$QT5WEBKIT_LIBDIR"  # this seems to be ignored - file a bug with Qt
    else
      QT5WEBKIT_CFLAGS="-I$with_qt5webkit/include"
      QT5WEBKIT_LDFLAGS="-L$with_qt5webkit/lib"
      QT5WEBKIT_LIBS="-lQt5WebKit -lQt5WebKitWidgets"
    fi
    AC_SUBST([QT5WEBKIT_CFLAGS])
    AC_SUBST([QT5WEBKIT_LDFLAGS])
    AC_SUBST([QT5WEBKIT_LIBS])
    AC_MSG_NOTICE([Using Qt5WebKit at $with_qt5webkit])
  ], [
    PKG_CHECK_MODULES(QT5WEBKIT, [Qt5WebKit Qt5WebKitWidgets], [AC_MSG_NOTICE([Found Qt5WebKit using pkg-config.])], [
      PKG_CHECK_MODULES(QT5WEBKIT, [QtWebKit >= 5 QtWebKitWidgets >= 5], [AC_MSG_NOTICE([Found QtWebKit >= 5 using pkg-config.])], [
        AC_MSG_ERROR([Qt5WebKit not found.])
      ])
    ])
  ])
  AC_SUBST([MACDEPLOYQT_LIBPATH])
  notbeginswith() { case $2 in "$1"*) true;; *) false;; esac; }
  if test "x$MOC" = "x" ; then
    AC_CHECK_TOOLS(MOC, [moc-qt5 moc])
  fi
  if notbeginswith "$($MOC -v)" "$MOC 5." ; then
    AC_MSG_ERROR([Cannot find Qt5 tool "moc" - please install the Qt5 development tools.])
  fi
  if test "x$UIC" = "x" ; then
    AC_CHECK_TOOLS(UIC, [uic-qt5 uic])
  fi
  if notbeginswith "$($UIC -v)" "$UIC 5." ; then
    AC_MSG_ERROR([Cannot find Qt5 tool "uic" - please install the Qt5 development tools.])
  fi
  if test "x$RCC" = "x" ; then
    AC_CHECK_TOOLS(RCC, [rcc-qt5 rcc])
  fi
  if notbeginswith "$($RCC -v)" "$RCC 5." ; then
    AC_MSG_ERROR([Cannot find Qt5 tool "rcc" - please install the Qt5 development tools.])
  fi
  if test "x$LRELEASE" = "x" ; then
    AC_CHECK_TOOLS(LRELEASE, [lrelease-qt5 lrelease])
  fi
  if notbeginswith "$($LRELEASE -version)" "lrelease version 5." ; then
    AC_MSG_ERROR([Cannot find Qt5 tool "lrelease" - please install the Qt5 translation tools.])
  fi
  if test "x$build_mac" = "xyes" ; then
    if test "x$MACDEPLOYQT" = "x" ; then
      AC_CHECK_TOOLS(MACDEPLOYQT, [macdeployqt-qt5 macdeployqt])
    fi
  fi
fi
AC_SUBST([MACOS_RPATH])

AM_CONDITIONAL([ENABLE_GUI], [test "$enable_gui" = "yes"])

AX_SUBDIRS_CONFIGURE([src/secp256k1], [[--disable-shared], [--with-pic], [--with-bignum=no], [--enable-module-recovery], [--enable-experimental], [--enable-module-ecdh]])
AX_SUBDIRS_CONFIGURE([tor], [[--disable-unittests], [--disable-system-torrc], [--disable-systemd], 
  [--disable-asciidoc], [--disable-shared], [--disable-gcc-hardening], [--disable-lzma], 
  [--disable-zstd], [--disable-asciidoc], [--disable-jni], [--disable-system-torrc], 
  [--with-openssl-dir=${openssl_dir}]])
AC_OUTPUT

dnl Taken from https://wiki.debian.org/RpathIssue
case $host in
   *-*-linux-gnu)
     AC_MSG_RESULT([Fixing libtool for -rpath problems.])
     sed < libtool > libtool-2 \
     's/^hardcode_libdir_flag_spec.*$'/'hardcode_libdir_flag_spec=" -D__LIBTOOL_IS_A_FOOL__ "/'
     mv libtool-2 libtool
     chmod 755 libtool
   ;;
esac

dnl Replace the BUILDDIR path with the correct Windows path if compiling on Native Windows
case ${OS} in
   *Windows*)
     sed  's/BUILDDIR="\/\([[a-z]]\)/BUILDDIR="\1:/'  test/config.ini > test/config-2.ini
     mv test/config-2.ini test/config.ini
   ;;
esac
