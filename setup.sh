#!/bin/bash

# install mingw

sudo apt-get install mingw32

# install sdl dev package in /usr/local/cross-tools/i686-w64-mingw32

sudo mkdir -p /usr/local/cross-tools/i686-w64-mingw32
sudo chmod a+w /usr/local/cross-tools/i686-w64-mingw32

wget https://www.libsdl.org/release/SDL-devel-1.2.15-mingw32.tar.gz
tar xvvf SDL-devel-1.2.15-mingw32.tar.gz
cp -R SDL-1.2.15/* /usr/local/cross-tools/i686-w64-mingw32
