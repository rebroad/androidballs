#!/bin/bash

set -e

echo "Building SDL2 for Windows..."

# Set cross-compiler environment variables
export CC=x86_64-w64-mingw32-gcc
export CXX=x86_64-w64-mingw32-g++
export AR=x86_64-w64-mingw32-ar
export RANLIB=x86_64-w64-mingw32-ranlib
export WINDRES=x86_64-w64-mingw32-windres

# Create build directory
mkdir -p build-windows
cd build-windows

# Configure SDL2 for Windows
../SDL/configure \
    --host=x86_64-w64-mingw32 \
    --prefix=$(pwd)/install \
    --enable-shared \
    --enable-static \
    --disable-video-vulkan \
    --disable-video-opengl \
    --disable-video-opengles \
    --disable-video-opengles2

# Build SDL2
make -j$(nproc)

# Install SDL2
make install

echo "SDL2 for Windows built successfully!"
echo "Headers: $(pwd)/install/include/SDL2/"
echo "Libraries: $(pwd)/install/lib/" 