#!/bin/bash

# Android build script for SDL Physics Apps
# This script creates unique app names to avoid overwriting previous apps

# Default values
BUILD_TYPE=${1:-debug}
ABI=${2:-arm64-v8a}
APP_NAME=${3:-"SDLPhysics"}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print functions
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

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check Android SDK installation
check_android_sdk() {
    print_status "Checking Android SDK installation..."
    
    # Check for Android SDK
    if [ -d "../../Android/sdk" ]; then
        ANDROID_SDK_PATH="../../Android/sdk"
        print_success "Android SDK found at $ANDROID_SDK_PATH"
    else
        print_error "Android SDK not found at ../../Android/sdk"
        print_error "Please install Android SDK or update the path"
        exit 1
    fi
    
    # Check for Android NDK
    NDK_PATH="$ANDROID_SDK_PATH/ndk/25.1.8937393"
    if [ -d "$NDK_PATH" ]; then
        print_success "Android NDK found at $NDK_PATH"
    else
        NDK_PATH="$ANDROID_SDK_PATH/ndk/27.0.12077973"
        if [ -d "$NDK_PATH" ]; then
            print_success "Android NDK found at $NDK_PATH"
        else
            print_error "Android NDK not found"
            print_error "Please install Android NDK or update the path"
            exit 1
        fi
    fi
    
    # Check for Android SDK tools
    if [ -d "$ANDROID_SDK_PATH/cmdline-tools/latest/bin" ]; then
        print_success "Android SDK tools found at $ANDROID_SDK_PATH/cmdline-tools/latest/bin"
    else
        print_error "Android SDK tools not found"
        print_error "Please install Android SDK Command Line Tools"
        exit 1
    fi
}

# Function to check SDL Android project
check_sdl_android_project() {
    print_status "Checking SDL Android project..."
    
    if [ ! -d "SDL/android-project" ]; then
        print_error "SDL Android project not found"
        print_error "Please ensure SDL is properly cloned"
        exit 1
    fi
    
    print_success "SDL Android project found"
}

# Function to prepare Android project with unique app name
prepare_android_project() {
    print_status "Preparing Android project for $APP_NAME..."
    
    # Create unique build directory
    ANDROID_BUILD_DIR="build-android-$APP_NAME"
    
    if [ ! -d "$ANDROID_BUILD_DIR" ]; then
        print_status "Copying SDL Android project template..."
        cp -r "SDL/android-project" "$ANDROID_BUILD_DIR"
    fi
    
    # Update app name in build.gradle
    print_status "Updating app name to $APP_NAME..."
    sed -i "s/namespace = \"org.libsdl.app\"/namespace = \"org.libsdl.$APP_NAME\"/" "$ANDROID_BUILD_DIR/app/build.gradle"
    
    # Update app name in strings.xml
    print_status "Updating app display name..."
    sed -i "s/<string name=\"app_name\">SDL App<\/string>/<string name=\"app_name\">$APP_NAME<\/string>/" "$ANDROID_BUILD_DIR/app/src/main/res/values/strings.xml"
    

    
    # Copy our source file
    print_status "Copying main.c for Android..."
    cp main-android.c "$ANDROID_BUILD_DIR/app/jni/src/main.c"
    
    # Update Android.mk
    print_status "Updating Android.mk..."
    sed -i 's/YourSourceHere\.c/main.c/' "$ANDROID_BUILD_DIR/app/jni/src/Android.mk"
    
    # Update Application.mk
    print_status "Updating Application.mk..."
    cat > "$ANDROID_BUILD_DIR/app/jni/Application.mk" << EOF
# Application.mk for $APP_NAME
APP_PLATFORM := android-21
APP_ABI := $ABI
APP_STL := c++_static
APP_OPTIM := $BUILD_TYPE
APP_CPPFLAGS += -fexceptions -frtti
EOF
    
    # Create local.properties
    print_status "Creating local.properties..."
    cat > "$ANDROID_BUILD_DIR/local.properties" << EOF
sdk.dir=/home/rebroad/Android/sdk
EOF
    
    # Copy custom app icon if it exists
    if [ -d "icon_physics_demo_tmp" ]; then
        print_status "Copying physics demo icon to mipmap directories..."
        for size in mdpi hdpi xhdpi xxhdpi xxxhdpi; do
            icon_src="icon_physics_demo_tmp/ic_launcher_${size}.png"
            icon_dst="$ANDROID_BUILD_DIR/app/src/main/res/mipmap-${size}/ic_launcher.png"
            if [ -f "$icon_src" ]; then
                cp "$icon_src" "$icon_dst"
            fi
        done
    fi
    
    print_success "Android project prepared for $APP_NAME"
}

# Function to build Android APK
build_android_apk() {
    print_status "Building Android APK for $APP_NAME..."
    
    cd "$ANDROID_BUILD_DIR"
    
    # Set environment variables
    export ANDROID_HOME="$ANDROID_SDK_PATH"
    export ANDROID_NDK_HOME="$NDK_PATH"
    
    # Build using Gradle
    print_status "Running Gradle build..."
    if [ "$BUILD_TYPE" = "debug" ]; then
        if ! ./gradlew assembleDebug; then
            print_error "Gradle build failed"
            exit 1
        fi
        APK_PATH="app/build/outputs/apk/debug/app-debug.apk"
    else
        if ! ./gradlew assembleRelease; then
            print_error "Gradle build failed"
            exit 1
        fi
        APK_PATH="app/build/outputs/apk/release/app-release.apk"
    fi
    
    if [ ! -f "$APK_PATH" ]; then
        print_error "APK build failed - APK not found at $APK_PATH"
        exit 1
    fi
    
    # Copy APK to project root with unique name
    cp "$APK_PATH" "../$APP_NAME-android-$BUILD_TYPE.apk"
    
    cd ..
    
    print_success "Android APK built successfully: $APP_NAME-android-$BUILD_TYPE.apk"
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
    adb install -r "$APP_NAME-android-$BUILD_TYPE.apk"
    print_success "APK installed successfully"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [BUILD_TYPE] [ABI] [APP_NAME]"
    echo ""
    echo "BUILD_TYPE: release (default) or debug"
    echo "ABI: armeabi-v7a, arm64-v8a (default), x86, x86_64, or all"
    echo "APP_NAME: Unique name for the app (default: SDLPhysics)"
    echo ""
    echo "Examples:"
    echo "  $0                                    # Build debug for arm64-v8a with default name"
    echo "  $0 debug arm64-v8a PhysicsDemo       # Build debug with custom name"
    echo "  $0 release all SensorTest             # Build release for all ABIs with custom name"
}

# Main execution
main() {
    print_status "Starting Android build for $APP_NAME"
    
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
    print_status "App name: $APP_NAME"
    
    # Run build steps
    check_android_sdk
    check_sdl_android_project
    prepare_android_project
    build_android_apk
    install_apk
    
    print_success "Android build completed successfully!"
    print_status "APK: $APP_NAME-android-$BUILD_TYPE.apk"
    print_status "Package name: org.libsdl.$APP_NAME"
}

# Run main function
main "$@" 