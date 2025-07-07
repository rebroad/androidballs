#!/bin/bash
# Build script for Linux SDL2 Hello World

set -e

echo "Building SDL2 for Linux..."

# Create build directory
mkdir -p build-linux
cd build-linux

# Configure SDL2
../../SDL/configure --prefix=$(pwd)/install --enable-shared=no --enable-static=yes

# Build SDL2
make -j$(nproc)

# Install SDL2 to our build directory
make install

cd ..

echo "Building Hello World app..."

# Build our app with the compiled SDL2
gcc -Wall -Wextra -std=c99 -O2 \
    -Ibuild-linux/install/include/SDL2 \
    -Lbuild-linux/install/lib \
    -o helloworld main.c \
    -lSDL2 -lm -lpthread -ldl

echo "Build complete! Run with: ./helloworld" 
