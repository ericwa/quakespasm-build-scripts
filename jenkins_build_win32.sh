#!/bin/bash

# This script is meant to be invoked by jenkins

cd $WORKSPACE/Quake

REVISION="r$SVN_REVISION$GIT_COMMIT"

# build_cross_win32.sh

TARGET=i586-mingw32msvc
PREFIX=/usr/local/cross-tools/i686-w64-mingw32

PATH="$PREFIX/bin:$PATH"
export PATH

MAKE_CMD=make

CC="$TARGET-gcc"
AS="$TARGET-as"
RANLIB="$TARGET-ranlib"
AR="$TARGET-ar"
WINDRES="$TARGET-windres"
STRIP="$TARGET-strip"
CFLAGS=""

if [[ -z "$SUFFIX_OVERRIDE" ]]; then
	CFLAGS="$CFLAGS -DQUAKESPASM_VER_SUFFIX=\"-dev-$REVISION\""
else
	CFLAGS="$CFLAGS -DQUAKESPASM_VER_SUFFIX=\"$SUFFIX_OVERRIDE\""
fi

export PATH CC AS AR RANLIB WINDRES STRIP

$MAKE_CMD -f Makefile.w32 clean

CFLAGS=$CFLAGS $MAKE_CMD CC=$CC AS=$AS RANLIB=$RANLIB AR=$AR WINDRES=$WINDRES STRIP=$STRIP DEBUG=$DEBUG -f Makefile.w32 USE_SDL2=$SDL2 $*
makestatus=$?

if [[ $makestatus != 0 ]]; then
	exit $makestatus
fi

# package it:

# rename the exe

mv $WORKSPACE/Quake/quakespasm.exe \
   $WORKSPACE/Quake/quakespasm-$REVISION.exe

# create the archive
# -j : don't store the full paths

#delete old archives
rm $WORKSPACE/quakespasm-*.zip

#pick the right dll to package
if [[ $SDL2 != 0 ]]; then
	SDL_DLL=$WORKSPACE/Windows/SDL2/lib/SDL2.dll
else
	SDL_DLL=$WORKSPACE/Windows/SDL/lib/SDL.dll
fi	

zip -9 -j $WORKSPACE/quakespasm-$REVISION.zip \
	$WORKSPACE/Quake/quakespasm-$REVISION.exe \
	$WORKSPACE/Quake/quakespasm.pak \
	$WORKSPACE/README.* \
	$WORKSPACE/gnu.txt \
	$WORKSPACE/Windows/codecs/x86/*.dll \
	$SDL_DLL

