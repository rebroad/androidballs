# SDL Hello World

A simple SDL Hello World application that works with both SDL2 and SDL3.

## Features

- **SDL2/SDL3 Compatibility**: Automatically detects whether the SDL directory contains SDL2 or SDL3
- **Multi-platform Builds**: Linux, Windows, and Android support
- **Unified Build Script**: Single `build.sh` script handles both Linux and Windows builds
- **Android Build Script**: Separate `build-android.sh` for Android APK generation
- **Flexible Linking**: Choose between static and dynamic linking
- **Cross-platform**: Build for Linux or cross-compile for Windows
- **System-wide SDL Detection**: Uses system-installed SDL if available, otherwise builds from source
- **API Compatibility**: Handles differences between SDL2 and SDL3 APIs

## Requirements

### For Linux builds:
- GCC compiler
- Make
- For SDL3 builds: CMake (`sudo apt-get install cmake`)

### For Windows cross-compilation:
- MinGW-w64 cross-compiler (`sudo apt-get install mingw-w64`)
- CMake (for SDL3 builds)

### For Android builds:
- Android SDK with NDK
- Java Development Kit (JDK)
- Gradle (included in Android project)

## Usage

### Unified Build Script
```bash
# Basic usage (Linux, static linking)
./build.sh

# Linux with dynamic linking
./build.sh linux dynamic

# Windows cross-compilation with static linking
./build.sh windows static

# Windows cross-compilation with dynamic linking
./build.sh windows dynamic

# Show help
./build.sh --help
```

### Android Build Script
```bash
# Basic usage (release build for arm64-v8a)
./build-android.sh

# Debug build
./build-android.sh debug

# Build for all ABIs
./build-android.sh release all

# Build for specific ABI
./build-android.sh debug armeabi-v7a

# Show help
./build-android.sh --help
```

### Legacy Scripts (Deprecated)
The old separate scripts are still available but deprecated:
- `build-linux.sh` - Use `./build.sh linux` instead
- `build-windows.sh` - Use `./build.sh windows` instead

## SDL Version Detection

The build script automatically detects the SDL version by checking for:
- `SDL/include/SDL3/` directory → SDL3
- `SDL/include/SDL2/` directory → SDL2

## API Differences Handled

The `main.c` file uses conditional compilation to handle API differences:

- **SDL2**: Uses `SDL_MAIN_HANDLED`, `SDL_main.h`, `SDL_WINDOW_SHOWN` flag
- **SDL3**: Uses `SDL_WINDOW_OPENGL` flag, different renderer creation

## Build Process

### Desktop Builds (Linux/Windows)
1. **Version Detection**: Scripts detect SDL2 vs SDL3
2. **System Check**: Look for system-wide SDL installation
3. **Source Build**: If not found, build from source using appropriate method:
   - SDL2: Autotools (`./configure`)
   - SDL3: CMake
4. **Compilation**: Compile with appropriate flags and libraries

### Android Builds
1. **SDK Check**: Verify Android SDK and NDK installation
2. **Project Setup**: Copy SDL Android project template
3. **Source Integration**: Replace placeholder with your `main.c`
4. **Gradle Build**: Build APK using Android Gradle plugin
5. **Installation**: Optionally install on connected device

## Link Types

### Static Linking (Default)
- All SDL code embedded in executable
- Larger file size but no external dependencies
- Good for distribution

### Dynamic Linking
- Links against shared libraries (.so/.dll)
- Smaller executable size
- Requires SDL runtime libraries on target system

## Troubleshooting

### Desktop Builds
- **CMake not found**: Install with `sudo apt-get install cmake`
- **MinGW not found**: Install with `sudo apt-get install mingw-w64`
- **SDL not detected**: Ensure SDL directory contains either SDL2 or SDL3 headers
- **Large executable size**: Use dynamic linking (`./build.sh [platform] dynamic`)

### Android Builds
- **Android SDK not found**: Install Android Studio or command-line tools
- **NDK not found**: Install via Android Studio SDK Manager or `sdkmanager ndk-bundle`
- **Gradle build fails**: Ensure JDK is installed and JAVA_HOME is set
- **APK installation fails**: Enable USB debugging on Android device 
