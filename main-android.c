#include <SDL3/SDL.h>
#include <SDL3/SDL_main.h>
#include <android/log.h>

#define LOG_TAG "SDLHelloWorld"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

#define NUM_OBJECTS 50

static int num_objects = NUM_OBJECTS;
static bool cycle_color = true;
static bool cycle_alpha = true;
static int cycle_direction = 1;
static int current_alpha = 255;
static int current_color = 255;
static Uint64 next_fps_check;
static Uint32 frames;
static const int fps_check_delay = 5000;

static void DrawPoints(SDL_Renderer *renderer)
{
    int i;
    float x, y;
    SDL_Rect viewport;

    /* Query the sizes */
    SDL_GetRenderViewport(renderer, &viewport);

    for (i = 0; i < num_objects * 4; ++i) {
        /* Cycle the color and alpha, if desired */
        if (cycle_color) {
            current_color += cycle_direction;
            if (current_color < 0) {
                current_color = 0;
                cycle_direction = -cycle_direction;
            }
            if (current_color > 255) {
                current_color = 255;
                cycle_direction = -cycle_direction;
            }
        }
        if (cycle_alpha) {
            current_alpha += cycle_direction;
            if (current_alpha < 0) {
                current_alpha = 0;
                cycle_direction = -cycle_direction;
            }
            if (current_alpha > 255) {
                current_alpha = 255;
                cycle_direction = -cycle_direction;
            }
        }
        SDL_SetRenderDrawColor(renderer, 255, (Uint8)current_color,
                               (Uint8)current_color, (Uint8)current_alpha);

        x = (float)SDL_rand(viewport.w);
        y = (float)SDL_rand(viewport.h);
        SDL_RenderPoint(renderer, x, y);
    }
}

static void DrawLines(SDL_Renderer *renderer)
{
    int i;
    float x1, y1, x2, y2;
    SDL_Rect viewport;

    /* Query the sizes */
    SDL_GetRenderViewport(renderer, &viewport);

    for (i = 0; i < num_objects; ++i) {
        /* Cycle the color and alpha, if desired */
        if (cycle_color) {
            current_color += cycle_direction;
            if (current_color < 0) {
                current_color = 0;
                cycle_direction = -cycle_direction;
            }
            if (current_color > 255) {
                current_color = 255;
                cycle_direction = -cycle_direction;
            }
        }
        if (cycle_alpha) {
            current_alpha += cycle_direction;
            if (current_alpha < 0) {
                current_alpha = 0;
                cycle_direction = -cycle_direction;
            }
            if (current_alpha > 255) {
                current_alpha = 255;
                cycle_direction = -cycle_direction;
            }
        }
        SDL_SetRenderDrawColor(renderer, 255, (Uint8)current_color,
                               (Uint8)current_color, (Uint8)current_alpha);

        if (i == 0) {
            SDL_RenderLine(renderer, 0.0f, 0.0f, (float)(viewport.w - 1), (float)(viewport.h - 1));
            SDL_RenderLine(renderer, 0.0f, (float)(viewport.h - 1), (float)(viewport.w - 1), 0.0f);
            SDL_RenderLine(renderer, 0.0f, (float)(viewport.h / 2), (float)(viewport.w - 1), (float)(viewport.h / 2));
            SDL_RenderLine(renderer, (float)(viewport.w / 2), 0.0f, (float)(viewport.w / 2), (float)(viewport.h - 1));
        } else {
            x1 = (float)(SDL_rand(viewport.w * 2) - viewport.w);
            x2 = (float)(SDL_rand(viewport.w * 2) - viewport.w);
            y1 = (float)(SDL_rand(viewport.h * 2) - viewport.h);
            y2 = (float)(SDL_rand(viewport.h * 2) - viewport.h);
            SDL_RenderLine(renderer, x1, y1, x2, y2);
        }
    }
}

static void DrawRects(SDL_Renderer *renderer)
{
    int i;
    SDL_FRect rect;
    SDL_Rect viewport;

    /* Query the sizes */
    SDL_GetRenderViewport(renderer, &viewport);

    for (i = 0; i < num_objects / 4; ++i) {
        /* Cycle the color and alpha, if desired */
        if (cycle_color) {
            current_color += cycle_direction;
            if (current_color < 0) {
                current_color = 0;
                cycle_direction = -cycle_direction;
            }
            if (current_color > 255) {
                current_color = 255;
                cycle_direction = -cycle_direction;
            }
        }
        if (cycle_alpha) {
            current_alpha += cycle_direction;
            if (current_alpha < 0) {
                current_alpha = 0;
                cycle_direction = -cycle_direction;
            }
            if (current_alpha > 255) {
                current_alpha = 255;
                cycle_direction = -cycle_direction;
            }
        }
        SDL_SetRenderDrawColor(renderer, 255, (Uint8)current_color,
                               (Uint8)current_color, (Uint8)current_alpha);

        rect.w = (float)SDL_rand(viewport.h / 2);
        rect.h = (float)SDL_rand(viewport.h / 2);
        rect.x = (SDL_rand(viewport.w * 2) - viewport.w) - (rect.w / 2);
        rect.y = (SDL_rand(viewport.h * 2) - viewport.h) - (rect.h / 2);
        SDL_RenderFillRect(renderer, &rect);
    }
}

int main(int argc, char *argv[]) {
    (void)argc; (void)argv;
    
    LOGI("=== SDL Drawing Test Starting ===");
    
    // Initialize SDL
    LOGI("Initializing SDL...");
    if (!SDL_Init(SDL_INIT_EVENTS | SDL_INIT_VIDEO)) {
        LOGE("SDL_Init failed (%s)", SDL_GetError());
        return 1;
    }
    LOGI("SDL initialized successfully");
    
    // Create window and renderer
    LOGI("Creating window and renderer...");
    SDL_Window *win = NULL;
    SDL_Renderer *ren = NULL;
    SDL_CreateWindowAndRenderer("SDL Drawing Test", 800, 600, SDL_WINDOW_RESIZABLE, &win, &ren);
    if (!win || !ren) {
        LOGE("Failed to create window or renderer: %s", SDL_GetError());
        SDL_Quit();
        return 1;
    }
    LOGI("Window and renderer created successfully");
    
    // Main event loop
    int quit = 0;
    SDL_Event event;
    Uint64 start_ticks = SDL_GetTicks();
    
    LOGI("Entering main event loop...");
    while (!quit) {
        // Handle events
        while (SDL_PollEvent(&event)) {
            switch (event.type) {
                case SDL_EVENT_QUIT:
                    LOGI("SDL_EVENT_QUIT event received");
                    quit = 1;
                    break;
                case SDL_EVENT_FINGER_DOWN:
                case SDL_EVENT_MOUSE_BUTTON_DOWN:
                    LOGI("Touch/click event received - exiting");
                    quit = 1;
                    break;
                case SDL_EVENT_WINDOW_CLOSE_REQUESTED:
                    LOGI("Window close event received");
                    quit = 1;
                    break;
            }
        }
        
        // Clear screen
        SDL_SetRenderDrawColor(ren, 0xA0, 0xA0, 0xA0, 0xFF);
        SDL_RenderClear(ren);
        
        // Draw animated shapes
        DrawRects(ren);
        DrawLines(ren);
        DrawPoints(ren);
        
        // Present the render
        SDL_RenderPresent(ren);
        
        // Cap frame rate
        SDL_Delay(16); // ~60 FPS
        
        // Exit after 10 seconds
        if (SDL_GetTicks() - start_ticks > 10000) {
            LOGI("10 seconds elapsed, exiting...");
            quit = 1;
        }
    }
    
    LOGI("Cleaning up...");
    SDL_DestroyRenderer(ren);
    SDL_DestroyWindow(win);
    SDL_Quit();
    
    LOGI("=== SDL Drawing Test Exiting ===");
    return 0;
} 