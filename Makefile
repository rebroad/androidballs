# Minimal Makefile for SDL2 Hello World
# Supports Linux and Windows (MinGW cross-compilation)

# Compiler settings
CC = gcc
CFLAGS = -Wall -Wextra -std=c99 -O2
LDFLAGS = -lSDL2 -lm

# SDL2 paths (adjust these if needed)
SDL_INCLUDE = ../SDL/include
SDL_LIB = 

# Source files
SOURCES = main.c
TARGET = helloworld

# Default target
all: $(TARGET)

# Build for Linux
linux: CFLAGS += -I$(SDL_INCLUDE)
linux: $(TARGET)

# Build for Windows (cross-compile from Linux)
windows: CC = x86_64-w64-mingw32-gcc
windows: CFLAGS += -I$(SDL_INCLUDE)
windows: LDFLAGS = -lSDL2 -lm
windows: TARGET = helloworld.exe
windows: $(TARGET)

# Build rules
$(TARGET): $(SOURCES)
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

# Clean
clean:
	rm -f $(TARGET) helloworld.exe

# Run (Linux only)
run: $(TARGET)
	./$(TARGET)

.PHONY: all linux windows clean run 
