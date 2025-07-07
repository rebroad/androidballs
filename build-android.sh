#!/bin/bash

# Android build script for SDL Hello World
# Uses SDL's Android project template and Android SDK

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
ANDROID_SDK_PATH="../../Android/sdk"
ANDROID_NDK_PATH="$ANDROID_SDK_PATH/ndk"
SDL_ANDROID_PROJECT="SDL/android-project"
BUILD_TYPE="${1:-release}"  # release or debug
ABI="${2:-arm64-v8a}"       # armeabi-v7a, arm64-v8a, x86, x86_64, or all

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to find Android NDK
find_ndk() {
    if [ -d "$ANDROID_NDK_PATH" ]; then
        # Find the latest NDK version
        NDK_VERSION=$(ls "$ANDROID_NDK_PATH" | grep -E '^[0-9]+\.[0-9]+\.[0-9]+' | sort -V | tail -n1)
        if [ -n "$NDK_VERSION" ]; then
            echo "$ANDROID_NDK_PATH/$NDK_VERSION"
            return 0
        fi
    fi
    return 1
}

# Function to find Android SDK tools
find_sdk_tools() {
    # Check for sdkmanager
    if [ -f "$ANDROID_SDK_PATH/cmdline-tools/latest/bin/sdkmanager" ]; then
        echo "$ANDROID_SDK_PATH/cmdline-tools/latest/bin"
        return 0
    fi
    
    # Check for older location
    if [ -f "$ANDROID_SDK_PATH/tools/bin/sdkmanager" ]; then
        echo "$ANDROID_SDK_PATH/tools/bin"
        return 0
    fi
    
    return 1
}

# Function to check Android SDK installation
check_android_sdk() {
    print_status "Checking Android SDK installation..."
    
    if [ ! -d "$ANDROID_SDK_PATH" ]; then
        print_error "Android SDK not found at $ANDROID_SDK_PATH"
        print_error "Please install Android SDK or update ANDROID_SDK_PATH"
        exit 1
    fi
    
    # Find NDK
    NDK_PATH=$(find_ndk)
    if [ -z "$NDK_PATH" ]; then
        print_error "Android NDK not found in $ANDROID_NDK_PATH"
        print_error "Please install Android NDK via Android Studio or sdkmanager"
        exit 1
    fi
    
    # Find SDK tools
    SDK_TOOLS_PATH=$(find_sdk_tools)
    if [ -z "$SDK_TOOLS_PATH" ]; then
        print_error "Android SDK tools not found"
        print_error "Please install Android SDK command-line tools"
        exit 1
    fi
    
    print_success "Android SDK found at $ANDROID_SDK_PATH"
    print_success "Android NDK found at $NDK_PATH"
    print_success "Android SDK tools found at $SDK_TOOLS_PATH"
    
    export ANDROID_HOME="$ANDROID_SDK_PATH"
    export ANDROID_NDK_HOME="$NDK_PATH"
    export PATH="$SDK_TOOLS_PATH:$PATH"
}

# Function to check SDL Android project
check_sdl_android_project() {
    print_status "Checking SDL Android project..."
    
    if [ ! -d "$SDL_ANDROID_PROJECT" ]; then
        print_error "SDL Android project not found at $SDL_ANDROID_PROJECT"
        print_error "Please ensure SDL is properly cloned"
        exit 1
    fi
    
    if [ ! -f "$SDL_ANDROID_PROJECT/app/jni/src/YourSourceHere.c" ]; then
        print_error "SDL Android project template files not found"
        exit 1
    fi
    
    print_success "SDL Android project found"
}

# Function to prepare Android project
prepare_android_project() {
    print_status "Preparing Android project..."
    
    # Create a copy of the SDL Android project
    ANDROID_BUILD_DIR="build-android"
    if [ -d "$ANDROID_BUILD_DIR" ]; then
        print_status "Removing existing Android build directory..."
        rm -rf "$ANDROID_BUILD_DIR"
    fi
    
    print_status "Copying SDL Android project template..."
    cp -r "$SDL_ANDROID_PROJECT" "$ANDROID_BUILD_DIR"
    
    # Replace the placeholder source with our main.c
    print_status "Replacing placeholder source with main.c..."
    cp main.c "$ANDROID_BUILD_DIR/app/jni/src/"
    
    # Update Android.mk to use our source file
    print_status "Updating Android.mk..."
    sed -i 's/YourSourceHere\.c/main.c/' "$ANDROID_BUILD_DIR/app/jni/src/Android.mk"
    
    # Update Application.mk for better compatibility
    print_status "Updating Application.mk..."
    cat > "$ANDROID_BUILD_DIR/app/jni/Application.mk" << EOF
# Application.mk for SDL Hello World
APP_PLATFORM := android-21
APP_ABI := $ABI
APP_STL := c++_static
APP_OPTIM := $BUILD_TYPE
APP_CPPFLAGS += -fexceptions -frtti
EOF
    
    # Create local.properties file for Gradle
    print_status "Creating local.properties..."
    cat > "$ANDROID_BUILD_DIR/local.properties" << EOF
sdk.dir=/home/rebroad/Android/sdk
ndk.dir=$NDK_PATH
EOF
    
    print_success "Android project prepared"
}

# Function to build Android APK
build_android_apk() {
    print_status "Building Android APK..."
    
    cd "$ANDROID_BUILD_DIR"
    
    # Set environment variables
    export ANDROID_HOME="$ANDROID_SDK_PATH"
    export ANDROID_NDK_HOME="$NDK_PATH"
    
    # Build using Gradle
    print_status "Running Gradle build..."
    if [ "$BUILD_TYPE" = "debug" ]; then
        ./gradlew assembleDebug
        APK_PATH="app/build/outputs/apk/debug/app-debug.apk"
    else
        ./gradlew assembleRelease
        APK_PATH="app/build/outputs/apk/release/app-release.apk"
    fi
    
    if [ ! -f "$APK_PATH" ]; then
        print_error "APK build failed"
        exit 1
    fi
    
    # Copy APK to project root
    cp "$APK_PATH" "../helloworld-android-$BUILD_TYPE.apk"
    
    cd ..
    
    print_success "Android APK built successfully: helloworld-android-$BUILD_TYPE.apk"
}

# Function to install APK on connected device
install_apk() {
    if ! command_exists adb; then
        print_warning "adb not found, skipping APK installation"
        return
    fi
    
    # Check if device is connected
    if ! adb devices | grep -q "device$"; then
        print_warning "No Android device connected, skipping APK installation"
        return
    fi
    
    print_status "Installing APK on connected device..."
    adb install -r "helloworld-android-$BUILD_TYPE.apk"
    print_success "APK installed successfully"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [BUILD_TYPE] [ABI]"
    echo ""
    echo "BUILD_TYPE: release (default) or debug"
    echo "ABI: armeabi-v7a, arm64-v8a (default), x86, x86_64, or all"
    echo ""
    echo "Examples:"
    echo "  $0                    # Build release for arm64-v8a"
    echo "  $0 debug              # Build debug for arm64-v8a"
    echo "  $0 release all        # Build release for all ABIs"
    echo "  $0 debug armeabi-v7a # Build debug for armeabi-v7a"
}

# Main execution
main() {
    print_status "Starting Android build for SDL Hello World"
    
    # Check arguments
    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        show_usage
        exit 0
    fi
    
    # Validate build type
    if [ "$BUILD_TYPE" != "release" ] && [ "$BUILD_TYPE" != "debug" ]; then
        print_error "Invalid build type: $BUILD_TYPE"
        print_error "Use 'release' or 'debug'"
        exit 1
    fi
    
    # Validate ABI
    case "$ABI" in
        armeabi-v7a|arm64-v8a|x86|x86_64|all)
            ;;
        *)
            print_error "Invalid ABI: $ABI"
            print_error "Use: armeabi-v7a, arm64-v8a, x86, x86_64, or all"
            exit 1
            ;;
    esac
    
    print_status "Build type: $BUILD_TYPE"
    print_status "Target ABI: $ABI"
    
    # Run build steps
    check_android_sdk
    check_sdl_android_project
    prepare_android_project
    build_android_apk
    install_apk
    
    print_success "Android build completed successfully!"
    print_status "APK: helloworld-android-$BUILD_TYPE.apk"
}

# Run main function
main "$@" 