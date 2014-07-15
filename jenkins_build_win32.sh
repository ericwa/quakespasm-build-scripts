#!/bin/bash

# This script is meant to be invoked by jenkins, and assumes SDL dev lib is installed in
# /usr/local/cross-tools/i686-w64-mingw32

cd $WORKSPACE/quakespasm/Quake

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
export PATH CC AS AR RANLIB WINDRES STRIP

$MAKE_CMD SDL_CONFIG=$SDL_CONFIG CC=$CC AS=$AS RANLIB=$RANLIB AR=$AR WINDRES=$WINDRES STRIP=$STRIP -f Makefile.w32 $*

# package it

rm -fr ~/temp
mkdir ~/temp
cd ~/temp
wget https://www.libsdl.org/release/SDL-1.2.15-win32.zip
unzip -X SDL-1.2.15-win32.zip

# -j : don't store the full paths

cd $WORKSPACE
zip -9 -j qs.zip \
	quakespasm/Quake/quakespasm.exe \
	quakespasm/README.* \
	quakespasm/gnu.txt \
	quakespasm/Windows/codecs/x86/*.dll \
	~/temp/SDL.dll
