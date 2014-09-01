#!/bin/bash

`/usr/local/osxcross/target/bin/osxcross-env`

# This script is meant to be invoked by jenkins, and assumes SDL dev lib is installed in
# /usr/local/cross-tools/i386-w64-mingw32

cd $WORKSPACE/Quake

patch -p3 < /usr/local/quakespasm-build-scripts/sdlframeworkpath.diff

# build_cross_osx.sh

rm -f	quakespasm.ppc \
	quakespasm.x86 \
	quakespasm.x86_64 \
	QuakeSpasm
make clean

OLDPATH=$PATH
MAKE_CMD=make

OSXBUILD=1
export OSXBUILD
STRIP=/bin/true
export STRIP

# x86
CC=i386-apple-darwin13-cc
AS=i386-apple-darwin13-as
AR=i386-apple-darwin13-ar
RANLIB=i386-apple-darwin13-ranlib
LIPO=i386-apple-darwin13-lipo
export CC AS AR RANLIB LIPO
SDL_FRAMEWORK_PATH=/usr/local/quakespasm-build-scripts/SDL-1.2.15-osx $MAKE_CMD MACH_TYPE=x86 -f Makefile.darwin $* || exit 1
i386-apple-darwin13-strip -S quakespasm || exit 1
mv quakespasm quakespasm.x86 || exit 1
$MAKE_CMD clean

# x86_64
CC=x86_64-apple-darwin13-cc
AS=x86_64-apple-darwin13-as
AR=x86_64-apple-darwin13-ar
RANLIB=x86_64-apple-darwin13-ranlib
LIPO=x86_64-apple-darwin13-lipo
export CC AS AR RANLIB LIPO
SDL_FRAMEWORK_PATH=/usr/local/quakespasm-build-scripts/SDL-1.2.15-osx $MAKE_CMD MACH_TYPE=x86_64 -f Makefile.darwin $* || exit 1
x86_64-apple-darwin13-strip -S quakespasm || exit 1
mv quakespasm quakespasm.x86_64 || exit 1
$MAKE_CMD clean

$LIPO -create -o QuakeSpasm quakespasm.x86 quakespasm.x86_64 || exit 1

# package it:

rm $WORKSPACE/quakespasm-*.zip
zip -9 -j $WORKSPACE/quakespasm-$REVISION.zip \
	$WORKSPACE/Quake/QuakeSpasm
