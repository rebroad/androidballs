#!/bin/bash
# Build script for Linux SDL2 Hello World

set -e

echo "Checking for system-wide SDL2..."

# Check if SDL2 is available system-wide
if pkg-config --exists sdl2; then
    echo "SDL2 found system-wide, using it..."
    SDL2_CFLAGS=$(pkg-config --cflags sdl2)
    SDL2_LIBS=$(pkg-config --libs sdl2)
    USE_SYSTEM_SDL2=true
else
    echo "SDL2 not found system-wide, building from source..."
    USE_SYSTEM_SDL2=false
    
    # Create build directory
    mkdir -p build-linux
    cd build-linux

    # Configure SDL2
    ../../SDL/configure --prefix=$(pwd)/install --enable-shared=no --enable-static=yes

    # Build SDL2
    make -j$(nproc)

    # Install SDL2 to our build directory
    make install
    
    # Install SDL2 system-wide
    echo "Installing SDL2 system-wide..."
    sudo cp -r install/* /usr/local/
    sudo ldconfig
    
    cd ..
    
    SDL2_CFLAGS="-I/usr/local/include/SDL2"
    SDL2_LIBS="-L/usr/local/lib -lSDL2"
fi

echo "Building Hello World app..."

# Build our app
gcc -Wall -Wextra -std=c99 -O2 \
    $SDL2_CFLAGS \
    -o helloworld main.c \
    $SDL2_LIBS -lm -lpthread -ldl

echo "Build complete! Run with: ./helloworld" 
