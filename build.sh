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

# Function to build SDL from source
build_sdl_from_source() {
    local sdl_version=$1
    local platform=$2
    local link_type=$3
    local build_dir=$4
    
    echo "Building $sdl_version from source..."
    
    # Create build directory
    mkdir -p $build_dir
    cd $build_dir

    if [ "$sdl_version" = "SDL2" ]; then
        # SDL2 uses autotools
        if [ "$platform" = "windows" ]; then
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
            # For Linux, enable both shared and static based on link type
            if [ "$link_type" = "dynamic" ]; then
                ../SDL/configure --prefix=$(pwd)/install --enable-shared=yes --enable-static=yes
            else
                ../SDL/configure --prefix=$(pwd)/install --enable-shared=no --enable-static=yes
            fi
        fi
        make -j$(nproc)
        make install
    else # SDL3
        # SDL3 uses CMake
        if ! command -v cmake &> /dev/null; then
            echo "cmake is required to build SDL3 from source. Installing cmake..."
            sudo apt-get update && sudo apt-get install -y cmake
        fi
        
        if [ "$platform" = "windows" ]; then
            cmake ../../SDL \
                -DCMAKE_INSTALL_PREFIX=$(pwd)/install \
                -DCMAKE_TOOLCHAIN_FILE=../../SDL/build-scripts/cmake-toolchain-mingw64-x86_64.cmake \
                -DSDL_STATIC=$([ "$link_type" = "static" ] && echo "ON" || echo "OFF") \
                -DSDL_SHARED=$([ "$link_type" = "dynamic" ] && echo "ON" || echo "OFF")
        else
            cmake ../SDL \
                -DCMAKE_INSTALL_PREFIX=$(pwd)/install \
                -DSDL_STATIC=$([ "$link_type" = "static" ] && echo "ON" || echo "OFF") \
                -DSDL_SHARED=$([ "$link_type" = "dynamic" ] && echo "ON" || echo "OFF")
        fi
        make -j$(nproc)
        make install
    fi
    
    # Install SDL system-wide
    echo "Installing $sdl_version system-wide..."
    sudo mkdir -p $SYSTEM_SDL_DIR
    sudo cp -r install/* $SYSTEM_SDL_DIR/
    if [ "$platform" = "linux" ]; then
        sudo ldconfig
    fi
    
    cd ..
}

# Function to handle binary naming (latest without suffix, rename existing)
handle_binary_naming() {
    local output_name=$1
    local link_type=$2
    local platform=$3

    # Determine the suffix and extension
    local suffix=""
    local ext=""
    if [ "$platform" = "windows" ]; then
        ext=".exe"
    fi
    if [ "$link_type" = "static" ]; then
        suffix="-static"
    else
        suffix="-dynamic"
    fi

    # If the target binary exists, check if it's the same type
    if [ -f "$output_name" ]; then
        echo "Existing binary found: $output_name"
        
        # Detect if existing binary is static or dynamic
        local existing_type=""
        if [ "$platform" = "windows" ]; then
            # For Windows PE32+, check for DLL dependencies using objdump
            # If it has DLL dependencies beyond system DLLs, it's dynamic
            # System DLLs we expect: KERNEL32.dll, msvcrt.dll, etc.
            local dll_count=$(objdump -p "$output_name" 2>/dev/null | grep -c "DLL Name:")
            if [ "$dll_count" -gt 0 ]; then
                # Check if it has non-system DLLs (like SDL3.dll)
                if objdump -p "$output_name" 2>/dev/null | grep -q "SDL3.dll"; then
                    existing_type="dynamic"
                else
                    # Only system DLLs, likely static
                    existing_type="static"
                fi
            else
                existing_type="static"
            fi
        else
            # For Linux, use ldd to check dependencies
            if ldd "$output_name" 2>/dev/null | grep -q "not a dynamic executable"; then
                existing_type="static"
            else
                existing_type="dynamic"
            fi
        fi
        
        echo "Existing binary type: $existing_type"
        echo "Requested build type: $link_type"
        
        # If same type, exit early
        if [ "$existing_type" = "$link_type" ]; then
            echo "Binary already exists with same linking type. Nothing to do."
            exit 0
        fi
        
        # Different type, rename existing binary
        local new_name="${output_name%$ext}$suffix$ext"
        echo "Renaming existing $output_name to $new_name"
        mv "$output_name" "$new_name"
    fi
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

# Check if we need to rebuild SDL for dynamic linking
if [ "$USE_SYSTEM_SDL" = "true" ] && [ "$LINK_TYPE" = "dynamic" ]; then
    need_rebuild=false
    
    if [ "$SDL_VERSION" = "SDL3" ] && [ "$PLATFORM" = "windows" ]; then
        if [ ! -f "$SYSTEM_SDL_DIR/lib/libSDL3.dll.a" ] && [ ! -f "$SYSTEM_SDL_DIR/bin/SDL3.dll" ]; then
            echo "SDL3 dynamic libraries not found. Rebuilding SDL3 with dynamic support..."
            need_rebuild=true
        fi
    elif [ "$SDL_VERSION" = "SDL3" ] && [ "$PLATFORM" = "linux" ]; then
        if [ ! -f "$SYSTEM_SDL_DIR/lib/libSDL3.so" ]; then
            echo "SDL3 shared libraries not found. Rebuilding SDL3 with dynamic support..."
            need_rebuild=true
        fi
    fi
    
    if [ "$need_rebuild" = "true" ]; then
        USE_SYSTEM_SDL=false
        # Force rebuild by removing build directory
        rm -rf $BUILD_DIR
    fi
fi

if [ "$USE_SYSTEM_SDL" = "false" ]; then
    build_sdl_from_source "$SDL_VERSION" "$PLATFORM" "$LINK_TYPE" "$BUILD_DIR"
    
    # Set up SDL flags after building
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

# Handle binary naming to avoid overwriting
handle_binary_naming "$OUTPUT_NAME" "$LINK_TYPE" "$PLATFORM"

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
    if [ "$LINK_TYPE" = "dynamic" ]; then
        echo "Note: For dynamic builds, make sure to copy SDL3.dll with the executable"
    fi
fi 