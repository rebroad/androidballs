# SDL Hello World & Physics Demo

A multi-platform SDL application with two variants:
- **Desktop**: Simple "Hello SDL" window (Linux/Windows)
- **Android**: Interactive physics simulation with bouncing balls

## Features

- **Multi-platform**: Linux, Windows, and Android support
- **SDL2/SDL3 Compatible**: Automatically detects and adapts to SDL version
- **Android Physics Demo**: Interactive ball physics with device sensors
- **Desktop Hello World**: Simple SDL window demonstration
- **Modern UI**: Custom app icons for Android builds
- **Android Ready**: Complete APK generation with proper signing

## Quick Start

### Desktop (Linux/Windows) - Hello World
```bash
# Build and run simple SDL window
./build.sh
```

### Android - Physics Demo
```bash
# Build and install physics simulation APK
./build-android.sh
```

## Requirements

- **Desktop**: GCC, Make, CMake (for SDL3)
- **Android**: Android SDK with NDK, JDK

## Build Options

### Desktop Builds (Hello World)
```bash
./build.sh [linux|windows] [static|dynamic]
```

### Android Builds (Physics Demo)
```bash
./build-android.sh [debug|release] [arm64-v8a|armeabi-v7a|all]
```

Run `./build.sh --help` or `./build-android.sh --help` for detailed options.

## Project Structure

- `main.c` - Simple "Hello SDL" window (desktop)
- `main-android.c` - Physics simulation with bouncing balls (Android)
- `build.sh` - Desktop build script (Linux/Windows)
- `build-android.sh` - Android APK build script
- `generate_icon.py` - Icon generation for different app variants
- `SDL/` - SDL library source (SDL2 or SDL3)

## Physics Demo Features (Android Only)

- Gravity simulation using device accelerometer
- Ball bouncing with energy loss
- Collision detection between balls
- Gyroscope-based rotation effects
- Realistic physics calculations
- Smooth 60 FPS rendering
- 6 colorful bouncing balls

## Troubleshooting

- **Build fails**: Ensure SDL directory contains valid SDL2 or SDL3 headers
- **Android APK won't install**: Enable USB debugging on device
- **Large executable**: Use dynamic linking (`./build.sh [platform] dynamic`)

## License

This project uses SDL which is licensed under the zlib license. 
