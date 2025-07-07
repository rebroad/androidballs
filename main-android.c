#include <SDL3/SDL.h>
#include <SDL3/SDL_main.h>
#include <android/log.h>

#define LOG_TAG "SDLHelloWorld"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

int main(int argc, char *argv[]) {
    (void)argc; (void)argv;
    
    LOGI("=== SDL Hello World Starting ===");
    LOGI("SDL version: SDL3");
    
    // Initialize SDL
    LOGI("Initializing SDL...");
    if (!SDL_Init(SDL_INIT_EVENTS | SDL_INIT_VIDEO)) {
        LOGE("SDL_Init failed (%s)", SDL_GetError());
        SDL_Delay(5000);
        return 1;
    }
    LOGI("SDL initialized successfully");
    
    // Create window and renderer
    LOGI("Creating window and renderer...");
    SDL_Window *win = NULL;
    SDL_Renderer *ren = NULL;
    SDL_CreateWindowAndRenderer("SDL Hello World", 800, 600, SDL_WINDOW_RESIZABLE, &win, &ren);
    if (!win || !ren) {
        LOGE("Failed to create window or renderer: %s", SDL_GetError());
        SDL_Delay(5000);
        SDL_Quit();
        return 1;
    }
    LOGI("Window and renderer created successfully");
    
    // Set render draw color to a nice pink
    SDL_SetRenderDrawColor(ren, 255, 105, 180, 255); // Hot pink
    LOGI("Render color set");
    SDL_RenderClear(ren);
    SDL_RenderPresent(ren);
    LOGI("Screen cleared and presented");
    
    // Show a message box to test
    LOGI("Showing message box...");
    if (!SDL_ShowSimpleMessageBox(SDL_MESSAGEBOX_INFORMATION, "Hello World",
                                 "!! Your SDL project successfully runs on Android !!", win)) {
        LOGE("SDL_ShowSimpleMessageBox failed (%s)", SDL_GetError());
        SDL_Delay(5000);
        SDL_DestroyRenderer(ren);
        SDL_DestroyWindow(win);
        SDL_Quit();
        return 1;
    }
    LOGI("Message box shown successfully");
    
    LOGI("Delaying for 5 seconds before exit...");
    SDL_Delay(5000);
    
    LOGI("Cleaning up...");
    SDL_DestroyRenderer(ren);
    SDL_DestroyWindow(win);
    SDL_Quit();
    
    LOGI("=== SDL Hello World Exiting ===");
    return 0;
} 