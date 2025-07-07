#!/bin/bash
# Unified build script for SDL2/SDL3 Hello World
# Usage: ./build.sh [linux|windows] [static|dynamic]

set -e

# Default values
PLATFORM=${1:-linux}
LINK_TYPE=${2:-static}

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

# Function to show usage
show_usage() {
    echo "Usage: $0 [linux|windows] [static|dynamic]"
    echo ""
    echo "Platforms:"
    echo "  linux    - Build for Linux (default)"
    echo "  windows  - Build for Windows (cross-compile)"
    echo ""
    echo "Link types:"
    echo "  static   - Static linking (default)"
    echo "  dynamic  - Dynamic/shared linking"
    echo ""
    echo "Examples:"
    echo "  $0                    # Linux, static"
    echo "  $0 linux dynamic      # Linux, dynamic"
    echo "  $0 windows static     # Windows, static"
    echo "  $0 windows dynamic    # Windows, dynamic"
}

# Validate arguments
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    show_usage
    exit 0
fi

if [ "$PLATFORM" != "linux" ] && [ "$PLATFORM" != "windows" ]; then
    echo "Error: Invalid platform '$PLATFORM'. Use 'linux' or 'windows'."
    show_usage
    exit 1
fi

if [ "$LINK_TYPE" != "static" ] && [ "$LINK_TYPE" != "dynamic" ]; then
    echo "Error: Invalid link type '$LINK_TYPE'. Use 'static' or 'dynamic'."
    show_usage
    exit 1
fi

SDL_VERSION=$(detect_sdl_version)
echo "Detected SDL version: $SDL_VERSION"
echo "Building for: $PLATFORM ($LINK_TYPE linking)"

if [ "$SDL_VERSION" = "Unknown" ]; then
    echo "Error: Could not detect SDL version. Please ensure SDL directory contains either SDL2 or SDL3."
    exit 1
fi

# Set up platform-specific variables
if [ "$PLATFORM" = "windows" ]; then
    # Windows cross-compilation setup
    export CC=x86_64-w64-mingw32-gcc
    export CXX=x86_64-w64-mingw32-g++
    export AR=x86_64-w64-mingw32-ar
    export RANLIB=x86_64-w64-mingw32-ranlib
    export WINDRES=x86_64-w64-mingw32-windres
    
    BUILD_DIR="build-windows"
    OUTPUT_NAME="helloworld.exe"
    SYSTEM_SDL_DIR="/usr/local/x86_64-w64-mingw32"
    COMPILER_PREFIX="x86_64-w64-mingw32-gcc"
    WINDOWS_LIBS="-lwinmm -lole32 -loleaut32 -lsetupapi -limm32 -lversion -luuid -luser32 -lgdi32 -lcomdlg32 -lshell32 -ladvapi32"
else
    # Linux setup
    BUILD_DIR="build-linux"
    OUTPUT_NAME="helloworld"
    SYSTEM_SDL_DIR="/usr/local"
    COMPILER_PREFIX="gcc"
    WINDOWS_LIBS=""
fi

echo "Checking for system-wide $SDL_VERSION..."

# Check if SDL is available system-wide
if [ "$SDL_VERSION" = "SDL2" ]; then
    if [ "$PLATFORM" = "windows" ]; then
        if [ -d "$SYSTEM_SDL_DIR/include/SDL2" ] && [ -d "$SYSTEM_SDL_DIR/lib" ]; then
            echo "Windows SDL2 found system-wide, using it..."
            SDL_CFLAGS="-I$SYSTEM_SDL_DIR/include/SDL2"
            SDL_LIBS="-L$SYSTEM_SDL_DIR/lib -lSDL2"
            USE_SYSTEM_SDL=true
        else
            echo "Windows SDL2 not found system-wide, building from source..."
            USE_SYSTEM_SDL=false
        fi
    else
        if pkg-config --exists sdl2; then
            echo "SDL2 found system-wide, using it..."
            SDL_CFLAGS=$(pkg-config --cflags sdl2)
            SDL_LIBS=$(pkg-config --libs sdl2)
            USE_SYSTEM_SDL=true
        else
            echo "SDL2 not found system-wide, building from source..."
            USE_SYSTEM_SDL=false
        fi
    fi
else # SDL3
    if [ "$PLATFORM" = "windows" ]; then
        if [ -d "$SYSTEM_SDL_DIR/include/SDL3" ] && [ -d "$SYSTEM_SDL_DIR/lib" ]; then
            echo "Windows SDL3 found system-wide, using it..."
            SDL_CFLAGS="-I$SYSTEM_SDL_DIR/include"
            SDL_LIBS="-L$SYSTEM_SDL_DIR/lib -lSDL3"
            USE_SYSTEM_SDL=true
        else
            echo "Windows SDL3 not found system-wide, building from source..."
            USE_SYSTEM_SDL=false
        fi
    else
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
fi

if [ "$USE_SYSTEM_SDL" = "false" ]; then
    # Create build directory
    mkdir -p $BUILD_DIR
    cd $BUILD_DIR

    # Configure and build SDL
    if [ "$SDL_VERSION" = "SDL2" ]; then
        # SDL2 uses autotools
        if [ "$PLATFORM" = "windows" ]; then
            ../../SDL/configure \
                --host=x86_64-w64-mingw32 \
                --prefix=$(pwd)/install \
                --enable-shared \
                --enable-static \
                --disable-video-vulkan \
                --disable-video-opengl \
                --disable-video-opengles \
                --disable-video-opengles2
        else
            ../SDL/configure --prefix=$(pwd)/install --enable-shared=no --enable-static=yes
        fi
        make -j$(nproc)
        make install
    else # SDL3
        # SDL3 uses CMake
        if ! command -v cmake &> /dev/null; then
            echo "cmake is required to build SDL3 from source. Installing cmake..."
            sudo apt-get update && sudo apt-get install -y cmake
        fi
        
        if [ "$PLATFORM" = "windows" ]; then
            cmake ../../SDL \
                -DCMAKE_INSTALL_PREFIX=$(pwd)/install \
                -DCMAKE_TOOLCHAIN_FILE=../../SDL/build-scripts/cmake-toolchain-mingw64-x86_64.cmake \
                -DSDL_STATIC=$([ "$LINK_TYPE" = "static" ] && echo "ON" || echo "OFF") \
                -DSDL_SHARED=$([ "$LINK_TYPE" = "dynamic" ] && echo "ON" || echo "OFF")
        else
            cmake ../SDL \
                -DCMAKE_INSTALL_PREFIX=$(pwd)/install \
                -DSDL_STATIC=$([ "$LINK_TYPE" = "static" ] && echo "ON" || echo "OFF") \
                -DSDL_SHARED=$([ "$LINK_TYPE" = "dynamic" ] && echo "ON" || echo "OFF")
        fi
        make -j$(nproc)
        make install
    fi
    
    # Install SDL system-wide
    echo "Installing $SDL_VERSION system-wide..."
    sudo mkdir -p $SYSTEM_SDL_DIR
    sudo cp -r install/* $SYSTEM_SDL_DIR/
    if [ "$PLATFORM" = "linux" ]; then
        sudo ldconfig
    fi
    
    cd ..
    
    if [ "$SDL_VERSION" = "SDL2" ]; then
        if [ "$PLATFORM" = "windows" ]; then
            SDL_CFLAGS="-I$SYSTEM_SDL_DIR/include/SDL2"
            SDL_LIBS="-L$SYSTEM_SDL_DIR/lib -lSDL2"
        else
            SDL_CFLAGS="-I$SYSTEM_SDL_DIR/include/SDL2"
            SDL_LIBS="-L$SYSTEM_SDL_DIR/lib -lSDL2"
        fi
    else # SDL3
        if [ "$PLATFORM" = "windows" ]; then
            SDL_CFLAGS="-I$SYSTEM_SDL_DIR/include"
            SDL_LIBS="-L$SYSTEM_SDL_DIR/lib -lSDL3"
        else
            SDL_CFLAGS="-I$SYSTEM_SDL_DIR/include"
            SDL_LIBS="-L$SYSTEM_SDL_DIR/lib -lSDL3"
        fi
    fi
fi

echo "Building Hello World app..."

# Build our app
if [ "$PLATFORM" = "windows" ]; then
    if [ "$SDL_VERSION" = "SDL2" ]; then
        $COMPILER_PREFIX -Wall -Wextra -std=c99 -O2 -s -flto \
            $SDL_CFLAGS \
            -DSDL2 \
            -o $OUTPUT_NAME main.c \
            -lSDL2main $SDL_LIBS -lm $WINDOWS_LIBS
    else # SDL3
        $COMPILER_PREFIX -Wall -Wextra -std=c99 -O2 -s -flto \
            $SDL_CFLAGS \
            -o $OUTPUT_NAME main.c \
            $SDL_LIBS -lm $WINDOWS_LIBS
    fi
else # Linux
    if [ "$SDL_VERSION" = "SDL2" ]; then
        $COMPILER_PREFIX -Wall -Wextra -std=c99 -O2 -s -flto \
            $SDL_CFLAGS \
            -DSDL2 \
            -o $OUTPUT_NAME main.c \
            $SDL_LIBS -lm -lpthread -ldl
    else # SDL3
        $COMPILER_PREFIX -Wall -Wextra -std=c99 -O2 -s -flto \
            $SDL_CFLAGS \
            -o $OUTPUT_NAME main.c \
            $SDL_LIBS -lm -lpthread -ldl
    fi
fi

echo "Build complete! Executable: $OUTPUT_NAME"
if [ "$PLATFORM" = "linux" ]; then
    echo "Run with: ./$OUTPUT_NAME"
else
    echo "Copy $OUTPUT_NAME to Windows to run it"
fi 