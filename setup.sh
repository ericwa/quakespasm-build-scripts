#!/bin/bash

DEST=/usr/local/cross-tools/i686-w64-mingw32
SDLVER=1.2.15
SDL2VER=2.0.3

# install mingw

sudo apt-get install mingw32

# install sdl dev package in /usr/local/cross-tools/i686-w64-mingw32

sudo mkdir -p $DEST
sudo chmod a+w $DEST

wget https://www.libsdl.org/release/SDL-devel-$SDLVER-mingw32.tar.gz
tar xvvf SDL-devel-$SDLVER-mingw32.tar.gz
cp -R SDL-$SDLVER/* $DEST

# also get SDL2

wget https://www.libsdl.org/release/SDL2-devel-$SDL2VER-mingw.tar.gz
tar xvvf SDL2-devel-$SDL2VER-mingw.tar.gz
cp -R SDL2-$SDL2VER/i686-w64-mingw32/* $DEST

# bah. Hack fix for http://stackoverflow.com/questions/22446008/winapifamily-h-no-such-file-or-directory-when-compiling-sdl-in-codeblocks

curl http://hg.libsdl.org/SDL/raw-file/e217ed463f25/include/SDL_platform.h > /usr/local/cross-tools/i686-w64-mingw32/include/SDL2/SDL_platform.h

