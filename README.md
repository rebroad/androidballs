# SDL2 Hello World

A minimal SDL2 Hello World application that displays a blue window.

## Prerequisites

- SDL2 source code (linked as `../SDL`)
- Android NDK r27 (linked as `../../Android`)
- GCC compiler (for Linux/Windows builds)
- MinGW-w64 (for Windows cross-compilation)

## Building

### Linux
```bash
make linux
./helloworld
```

### Windows (cross-compile from Linux)
```bash
# Install MinGW-w64 first: sudo apt install mingw-w64
make windows
# Copy helloworld.exe to Windows and run
```

### Android
```bash
# Build for all architectures
../../Android/ndk-r27/ndk-build

# Or build for specific architecture
../../Android/ndk-r27/ndk-build APP_ABI=arm64-v8a
```

## Project Structure

- `main.c` - Source code
- `Makefile` - Linux/Windows build configuration
- `Android.mk` - Android build configuration
- `Application.mk` - Android build settings
- `../SDL` - Symbolic link to SDL2 source
- `../../Android` - Symbolic link to Android NDK

## Notes

- The app creates a 640x480 window with a cornflower blue background
- It runs for 3 seconds then exits
- For Android, you'll need to create an APK with the built libraries 
