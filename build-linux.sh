#!/bin/bash
# Build script for Linux SDL2/SDL3 Hello World

set -e

# Function to detect SDL version
detect_sdl_version() {
    if [ -d "SDL/include/SDL3" ]; then
        echo "SDL3"
    elif [ -d "SDL/include/SDL2" ]; then
        echo "SDL2"
    else
        echo "Unknown"
    fi
}

SDL_VERSION=$(detect_sdl_version)
echo "Detected SDL version: $SDL_VERSION"

if [ "$SDL_VERSION" = "Unknown" ]; then
    echo "Error: Could not detect SDL version. Please ensure SDL directory contains either SDL2 or SDL3."
    exit 1
fi

echo "Checking for system-wide $SDL_VERSION..."

# Check if SDL is available system-wide
if [ "$SDL_VERSION" = "SDL2" ]; then
    if pkg-config --exists sdl2; then
        echo "SDL2 found system-wide, using it..."
        SDL_CFLAGS=$(pkg-config --cflags sdl2)
        SDL_LIBS=$(pkg-config --libs sdl2)
        USE_SYSTEM_SDL=true
    else
        echo "SDL2 not found system-wide, building from source..."
        USE_SYSTEM_SDL=false
    fi
else # SDL3
    if pkg-config --exists sdl3; then
        echo "SDL3 found system-wide, using it..."
        SDL_CFLAGS=$(pkg-config --cflags sdl3)
        SDL_LIBS=$(pkg-config --libs sdl3)
        USE_SYSTEM_SDL=true
    else
        echo "SDL3 not found system-wide, building from source..."
        USE_SYSTEM_SDL=false
    fi
fi

if [ "$USE_SYSTEM_SDL" = "false" ]; then
    # Create build directory
    mkdir -p build-linux
    cd build-linux

    # Configure and build SDL
    if [ "$SDL_VERSION" = "SDL2" ]; then
        # SDL2 uses autotools
        ../SDL/configure --prefix=$(pwd)/install --enable-shared=no --enable-static=yes
        make -j$(nproc)
        make install
    else # SDL3
        # SDL3 uses CMake
        if ! command -v cmake &> /dev/null; then
            echo "cmake is required to build SDL3 from source. Installing cmake..."
            sudo apt-get update && sudo apt-get install -y cmake
        fi
        cmake ../SDL -DCMAKE_INSTALL_PREFIX=$(pwd)/install -DSDL_STATIC=ON -DSDL_SHARED=OFF
        make -j$(nproc)
        make install
    fi
    
    # Install SDL system-wide
    echo "Installing $SDL_VERSION system-wide..."
    sudo cp -r install/* /usr/local/
    sudo ldconfig
    
    cd ..
    
    if [ "$SDL_VERSION" = "SDL2" ]; then
        SDL_CFLAGS="-I/usr/local/include/SDL2"
        SDL_LIBS="-L/usr/local/lib -lSDL2"
    else # SDL3
        SDL_CFLAGS="-I/usr/local/include"
        SDL_LIBS="-L/usr/local/lib -lSDL3"
    fi
fi

echo "Building Hello World app..."

# Build our app
if [ "$SDL_VERSION" = "SDL2" ]; then
    gcc -Wall -Wextra -std=c99 -O2 \
        $SDL_CFLAGS \
        -DSDL2 \
        -o helloworld main.c \
        $SDL_LIBS -lm -lpthread -ldl
else # SDL3
    gcc -Wall -Wextra -std=c99 -O2 \
        $SDL_CFLAGS \
        -o helloworld main.c \
        $SDL_LIBS -lm -lpthread -ldl
fi

echo "Build complete! Run with: ./helloworld" 
