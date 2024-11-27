#!/bin/bash -e
export LC_ALL=C

set -e

[ -d .git ] && [ -d tor ] && [ -d leveldb ] || \
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

echo "Configure secp256k1 subtree"
(cd "${srcdir}/src/secp256k1" && ./autogen.sh)

cd ..
cd tor && ./autogen.sh



