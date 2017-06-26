#!/bin/bash


GCC_VERSION="5.3.0"
WORKDIR="$HOME/src/"
INSTALLDIR="/platform"

../gcc-${GCC_VERSION}/configure                      \
    --prefix=${INSTALLDIR}                           \
    --enable-shared                                  \
    --enable-threads=posix                           \
    --enable-__cxa_atexit                            \
    --enable-clocale=gnu                             \
    --enable-languages=all                           \
    --enable-multilib				     \
    --with-sysroot				     \
&& make \
&& make install
