# Application.mk for SDL2 Hello World
# This file configures the Android NDK build

# Target Android API level (minimum supported)
APP_PLATFORM := android-21

# Target architectures
APP_ABI := armeabi-v7a arm64-v8a x86 x86_64

# C++ standard library
APP_STL := c++_static

# Optimization level
APP_OPTIM := release

# Enable C++ exceptions and RTTI
APP_CPPFLAGS += -fexceptions -frtti 