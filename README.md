# SDL Hello World

A simple SDL Hello World application that works with both SDL2 and SDL3.

## Features

- **SDL2/SDL3 Compatibility**: Automatically detects whether the SDL directory contains SDL2 or SDL3
- **Cross-platform Build Scripts**: 
  - `build-linux.sh` - Builds for Linux
  - `build-windows.sh` - Cross-compiles for Windows using MinGW
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

## Usage

### Linux Build
```bash
./build-linux.sh
```

### Windows Cross-compilation
```bash
./build-windows.sh
```

## SDL Version Detection

The build scripts automatically detect the SDL version by checking for:
- `SDL/include/SDL3/` directory → SDL3
- `SDL/include/SDL2/` directory → SDL2

## API Differences Handled

The `main.c` file uses conditional compilation to handle API differences:

- **SDL2**: Uses `SDL_MAIN_HANDLED`, `SDL_main.h`, `SDL_WINDOW_SHOWN` flag
- **SDL3**: Uses `SDL_WINDOW_OPENGL` flag, different renderer creation

## Build Process

1. **Version Detection**: Scripts detect SDL2 vs SDL3
2. **System Check**: Look for system-wide SDL installation
3. **Source Build**: If not found, build from source using appropriate method:
   - SDL2: Autotools (`./configure`)
   - SDL3: CMake
4. **Compilation**: Compile with appropriate flags and libraries

## Troubleshooting

- **CMake not found**: Install with `sudo apt-get install cmake`
- **MinGW not found**: Install with `sudo apt-get install mingw-w64`
- **SDL not detected**: Ensure SDL directory contains either SDL2 or SDL3 headers 
