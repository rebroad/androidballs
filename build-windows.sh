#!/bin/bash

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

echo "Building $SDL_VERSION for Windows..."

# Set cross-compiler environment variables
export CC=x86_64-w64-mingw32-gcc
export CXX=x86_64-w64-mingw32-g++
export AR=x86_64-w64-mingw32-ar
export RANLIB=x86_64-w64-mingw32-ranlib
export WINDRES=x86_64-w64-mingw32-windres

# Check if Windows SDL is available system-wide
WINDOWS_SDL_DIR="/usr/local/x86_64-w64-mingw32"
if [ "$SDL_VERSION" = "SDL2" ]; then
    if [ -d "$WINDOWS_SDL_DIR/include/SDL2" ] && [ -d "$WINDOWS_SDL_DIR/lib" ]; then
        echo "Windows SDL2 found system-wide, using it..."
        SDL_CFLAGS="-I$WINDOWS_SDL_DIR/include/SDL2"
        SDL_LIBS="-L$WINDOWS_SDL_DIR/lib -lSDL2"
        USE_SYSTEM_SDL=true
    else
        echo "Windows SDL2 not found system-wide, building from source..."
        USE_SYSTEM_SDL=false
    fi
else # SDL3
    if [ -d "$WINDOWS_SDL_DIR/include/SDL3" ] && [ -d "$WINDOWS_SDL_DIR/lib" ]; then
        echo "Windows SDL3 found system-wide, using it..."
        SDL_CFLAGS="-I$WINDOWS_SDL_DIR/include/SDL3"
        SDL_LIBS="-L$WINDOWS_SDL_DIR/lib -lSDL3"
        USE_SYSTEM_SDL=true
    else
        echo "Windows SDL3 not found system-wide, building from source..."
        USE_SYSTEM_SDL=false
    fi
fi

if [ "$USE_SYSTEM_SDL" = "false" ]; then
    # Create build directory
    mkdir -p build-windows
    cd build-windows

    # Configure and build SDL for Windows
    if [ "$SDL_VERSION" = "SDL2" ]; then
        # SDL2 uses autotools
        ../../SDL/configure \
            --host=x86_64-w64-mingw32 \
            --prefix=$(pwd)/install \
            --enable-shared \
            --enable-static \
            --disable-video-vulkan \
            --disable-video-opengl \
            --disable-video-opengles \
            --disable-video-opengles2
        make -j$(nproc)
        make install
    else # SDL3
        # SDL3 uses CMake
        if ! command -v cmake &> /dev/null; then
            echo "Error: cmake is required to build SDL3 from source."
            echo "Please install cmake: sudo apt-get install cmake"
            echo "Or use system SDL3 if available."
            exit 1
        fi
        cmake ../../SDL \
            -DCMAKE_INSTALL_PREFIX=$(pwd)/install \
            -DCMAKE_TOOLCHAIN_FILE=../../SDL/build-scripts/cmake-toolchain-mingw64-x86_64.cmake \
            -DSDL_STATIC=ON \
            -DSDL_SHARED=OFF
        make -j$(nproc)
        make install
    fi
    
    # Install SDL system-wide for Windows cross-compilation
    echo "Installing Windows $SDL_VERSION system-wide..."
    sudo mkdir -p $WINDOWS_SDL_DIR
    sudo cp -r install/* $WINDOWS_SDL_DIR/
    
    cd ..
    
    if [ "$SDL_VERSION" = "SDL2" ]; then
        SDL_CFLAGS="-I$WINDOWS_SDL_DIR/include/SDL2"
        SDL_LIBS="-L$WINDOWS_SDL_DIR/lib -lSDL2"
    else # SDL3
        SDL_CFLAGS="-I$WINDOWS_SDL_DIR/include/SDL3"
        SDL_LIBS="-L$WINDOWS_SDL_DIR/lib -lSDL3"
    fi
fi

echo "Building Windows Hello World executable..."

# Build our app for Windows
if [ "$SDL_VERSION" = "SDL2" ]; then
    x86_64-w64-mingw32-gcc -Wall -Wextra -std=c99 -O2 \
        $SDL_CFLAGS \
        -DSDL2 \
        -o helloworld.exe main.c \
        -lSDL2main $SDL_LIBS -lm
else # SDL3
    x86_64-w64-mingw32-gcc -Wall -Wextra -std=c99 -O2 \
        $SDL_CFLAGS \
        -o helloworld.exe main.c \
        $SDL_LIBS -lm
fi

echo "Windows build complete! Executable: helloworld.exe" 