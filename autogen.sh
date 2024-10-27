#!/bin/bash -e
export LC_ALL=C

set -e

[ -d .git ] && [ -d tor ] && [ -d leveldb ] && [ -d db4.8 ] || \
  { echo "Please run this command from the root of the TokenPay repository." && exit 1; }

git submodule update --init --recursive

srcdir="$(dirname $0)"
cd "$srcdir"
if [ -z "${LIBTOOLIZE}" ] && GLIBTOOLIZE="$(command -v glibtoolize)"; then
  LIBTOOLIZE="${GLIBTOOLIZE}"
  export LIBTOOLIZE
fi
command -v autoreconf >/dev/null || \
  (echo "configuration failed, please install autoconf first" && exit 1)
autoreconf --install --force --warnings=all

cd tor && ./autogen.sh

