#!/bin/bash

set -e

echo "Building SDL2 for Windows..."

# Set cross-compiler environment variables
export CC=x86_64-w64-mingw32-gcc
export CXX=x86_64-w64-mingw32-g++
export AR=x86_64-w64-mingw32-ar
export RANLIB=x86_64-w64-mingw32-ranlib
export WINDRES=x86_64-w64-mingw32-windres

# Check if Windows SDL2 is available system-wide
WINDOWS_SDL2_DIR="/usr/local/x86_64-w64-mingw32"
if [ -d "$WINDOWS_SDL2_DIR/include/SDL2" ] && [ -d "$WINDOWS_SDL2_DIR/lib" ]; then
    echo "Windows SDL2 found system-wide, using it..."
    SDL2_CFLAGS="-I$WINDOWS_SDL2_DIR/include/SDL2"
    SDL2_LIBS="-L$WINDOWS_SDL2_DIR/lib -lSDL2"
    USE_SYSTEM_SDL2=true
else
    echo "Windows SDL2 not found system-wide, building from source..."
    USE_SYSTEM_SDL2=false
    
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

    # Install SDL2 to our build directory
    make install
    
    # Install SDL2 system-wide for Windows cross-compilation
    echo "Installing Windows SDL2 system-wide..."
    sudo mkdir -p $WINDOWS_SDL2_DIR
    sudo cp -r install/* $WINDOWS_SDL2_DIR/
    
    cd ..
    
    SDL2_CFLAGS="-I$WINDOWS_SDL2_DIR/include/SDL2"
    SDL2_LIBS="-L$WINDOWS_SDL2_DIR/lib -lSDL2"
fi

echo "Building Windows Hello World executable..."

# Build our app for Windows
x86_64-w64-mingw32-gcc -Wall -Wextra -std=c99 -O2 \
    $SDL2_CFLAGS \
    -o helloworld.exe main.c \
    $SDL2_LIBS -lm

echo "Windows build complete! Executable: helloworld.exe" 