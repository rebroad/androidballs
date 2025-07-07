# Android.mk for SDL2 Hello World
# Simple build that links against SDL2

LOCAL_PATH := $(call my-dir)

# Build your app
include $(CLEAR_VARS)
LOCAL_MODULE := helloworld
LOCAL_SRC_FILES := main.c
LOCAL_C_INCLUDES := $(LOCAL_PATH)/...SDL/include
LOCAL_CFLAGS := -DANDROID
LOCAL_LDLIBS := -llog -landroid -lEGL -lGLESv1_CM -lGLESv2 -lOpenSLES

# For now, we'll build without SDL2 to test the basic setup
# TODO: Add SDL2 library linking once we have a proper Android SDL2 build

include $(call all-subdir-makefiles)

include $(BUILD_SHARED_LIBRARY) 