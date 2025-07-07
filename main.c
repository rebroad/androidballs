#ifdef SDL2
#define SDL_MAIN_HANDLED
#include "SDL_main.h"
#include "SDL.h"
#else
#include "SDL3/SDL.h"
#endif

int main(int argc, char *argv[]) {
	(void)argc; (void)argv;
    SDL_Init(SDL_INIT_VIDEO);
    
#ifdef SDL2
    SDL_Window *win = SDL_CreateWindow("Hello SDL",
        SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, 640, 480, SDL_WINDOW_SHOWN);
    SDL_Renderer *ren = SDL_CreateRenderer(win, -1, SDL_RENDERER_ACCELERATED);
#else
    SDL_Window *win = NULL;
    SDL_Renderer *ren = NULL;
    SDL_CreateWindowAndRenderer("Hello SDL", 640, 480, 0, &win, &ren);
#endif
    
    SDL_SetRenderDrawColor(ren, 100, 149, 237, 255); // cornflower blue!
    SDL_RenderClear(ren);
    SDL_RenderPresent(ren);
    SDL_Delay(3000);
    SDL_Quit();
    return 0;
}
