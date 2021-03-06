#!/bin/bash

cd $SRC_DIR/c++/

export CFLAGS="$CFLAGS -O2"
export CXXFLAGS="$CXXFLAGS -O2"
export CPPFLAGS="$CPPFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"

if test x"`uname`" = x"Linux"; then
    # only add things needed; not supported by OSX ld
    LDFLAGS="$LDFLAGS -Wl,-as-needed"
fi

LIB_INSTALL_DIR=$PREFIX/lib/ncbi-sparcle

# with/without options:
#
# dll: enable dynamic linking
# mt: enable multi-threading
# -autodep: no automatic dependency build (one time build)
# -makefile-auto-update: no rebuild of makefile (one time build)
# flat-makefile: use single makefile
# -caution: disable configure script warnings
# -dbapi: don't build database connectivity libs
# -lzo: don't add lzo support
# runpath: set runpath for installed $PREFIX location
# hard-runpath: disable new dtags (disallow LD_LIBRARY_PATH override on Linux)
# -debug: disable debug
# strip: remove debugging symbols (size!)
# -vdb: disable VDB/SRA toolkit
# z: set zlib
# bz2: set libbz2
# boost: set boost
# -openssl: disable openssl
# -gcrypt: disable gcrypt (needed on OSX)
# gnutls: set gnutls (preferred over openssl for -remote support)
# nettle: set nettle
# -krb5: disable kerberos (needed on OSX)

./configure \
    --with-dll \
    --with-mt \
    --without-autodep \
    --without-makefile-auto-update \
    --with-flat-makefile \
    --without-caution \
    --without-dbapi \
    --without-lzo \
    --with-hard-runpath \
    --without-lmdb \
    --with-runpath=$LIB_INSTALL_DIR \
    --without-debug \
    --without-bdb \
    --with-strip \
    --without-vdb \
    --with-z=$PREFIX \
    --with-bz2=$PREFIX \
    --with-boost=$PREFIX \
    --without-openssl \
    --without-gcrypt \
    --with-gnutls=$PREFIX \
    --with-nettle=$PREFIX \
    --without-krb5

projects="app/rpsbproc/"
cd ReleaseMT

# The "datatool" binary needs the libs at build time, create
# link from final install path to lib build dir:
ln -s $SRC_DIR/c++/ReleaseMT/lib $LIB_INSTALL_DIR

cd build
make -j${CPU_COUNT} -f Makefile.flat all_projects="$projects"

# remove temporary link
rm $LIB_INSTALL_DIR

mkdir -p $PREFIX/bin $LIB_INSTALL_DIR
cp $SRC_DIR/c++/ReleaseMT/bin/rpsbproc $PREFIX/bin/
cp $SRC_DIR/c++/ReleaseMT/lib/* $LIB_INSTALL_DIR
chmod +x $PREFIX/bin/rpsbproc
