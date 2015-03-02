#!/bin/bash

`/usr/local/osxcross/target/bin/osxcross-env`

# This script is meant to be invoked by jenkins, and assumes SDL frameworks are installed in
# /usr/local/quakespasm-build-scripts/Frameworks

cd $WORKSPACE/Quake

REVISION="r$SVN_REVISION$GIT_COMMIT"

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

SDL_FRAMEWORK_NAME=SDL
CFLAGS=""

# use SDL2 if requested
if [[ $SDL2 != 0 ]]; then
	SDL_FRAMEWORK_NAME=SDL2
	CFLAGS="-DUSE_SDL2"
fi

# x86
CC=i386-apple-darwin13-cc
AS=i386-apple-darwin13-as
AR=i386-apple-darwin13-ar
RANLIB=i386-apple-darwin13-ranlib
LIPO=i386-apple-darwin13-lipo
export CC AS AR RANLIB LIPO
CFLAGS=$CFLAGS $MAKE_CMD MACH_TYPE=x86 USE_SDL2=$SDL2 -f Makefile.darwin $* || exit 1
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
CFLAGS=$CFLAGS $MAKE_CMD MACH_TYPE=x86_64 USE_SDL2=$SDL2 -f Makefile.darwin $* || exit 1
x86_64-apple-darwin13-strip -S quakespasm || exit 1
mv quakespasm quakespasm.x86_64 || exit 1
$MAKE_CMD clean

$LIPO -create -o QuakeSpasm quakespasm.x86 quakespasm.x86_64 || exit 1

# package it:

APPDIR=QuakeSpasm-$REVISION.app
mkdir -p $APPDIR/Contents/Frameworks $APPDIR/Contents/MacOS $APPDIR/Contents/Resources
cp -R ../MacOSX/$SDL_FRAMEWORK_NAME.framework $APPDIR/Contents/Frameworks || exit 1
cp ../MacOSX/Info.plist $APPDIR/Contents || exit 1
cp QuakeSpasm $APPDIR/Contents/MacOS || exit 1
cp ../MacOSX/codecs/lib/*.dylib $APPDIR/Contents/MacOS || exit 1
cp -R ../MacOSX/English.lproj $APPDIR/Contents/Resources || exit 1
cp ../MacOSX/QuakeSpasm.icns $APPDIR/Contents/Resources || exit 1

# Fix up executable name in plist
perl -pi -e 's/\$\{EXECUTABLE_NAME\}/QuakeSpasm/g' $APPDIR/Contents/Info.plist

# Zip it
rm $WORKSPACE/quakespasm-*.zip
zip -9 --recurse-paths $WORKSPACE/quakespasm-$REVISION-osx.zip $APPDIR
