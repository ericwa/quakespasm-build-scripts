#!/bin/bash

# This script is meant to be invoked by jenkins, and assumes SDL dev lib is installed in
# /usr/local/cross-tools/i686-w64-mingw32

cd $WORKSPACE/Quake

REVISION="r$SVN_REVISION$GIT_COMMIT"

# build_cross_win32.sh

TARGET=i586-mingw32msvc
PREFIX=/usr/local/cross-tools/i686-w64-mingw32

PATH="$PREFIX/bin:$PATH"
export PATH

MAKE_CMD=make

SDL_CONFIG=sdl-config
CC="$TARGET-gcc"
AS="$TARGET-as"
RANLIB="$TARGET-ranlib"
AR="$TARGET-ar"
WINDRES="$TARGET-windres"
STRIP="$TARGET-strip"
CFLAGS=""

# use SDL2 if requested
if [[ $SDL2 != 0 ]]; then
	SDL_CONFIG=sdl2-config
	CFLAGS="-DUSE_SDL2"
fi

export PATH CC AS AR RANLIB WINDRES STRIP

$MAKE_CMD -f Makefile.w32 clean

CFLAGS=$CFLAGS $MAKE_CMD SDL_CONFIG=$SDL_CONFIG CC=$CC AS=$AS RANLIB=$RANLIB AR=$AR WINDRES=$WINDRES STRIP=$STRIP -f Makefile.w32 $*
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
	SDL_DLL=/usr/local/cross-tools/i686-w64-mingw32/bin/SDL2.dll
else
	SDL_DLL=/usr/local/cross-tools/i686-w64-mingw32/bin/SDL.dll
fi	

zip -9 -j $WORKSPACE/quakespasm-$REVISION.zip \
	$WORKSPACE/Quake/quakespasm-$REVISION.exe \
	$WORKSPACE/Quake/quakespasm.pak \
	$WORKSPACE/README.* \
	$WORKSPACE/gnu.txt \
	$WORKSPACE/Windows/codecs/x86/*.dll \
	$SDL_DLL

# SDL.dll is the one from https://www.libsdl.org/release/SDL-devel-1.2.15-mingw32.tar.gz
# installed in the setup script. It differs from https://www.libsdl.org/release/SDL-1.2.15-win32.zip

