#include "SDL.h"

int main(int argc, char *argv[]) {
    SDL_Init(SDL_INIT_VIDEO);
    SDL_Window *win = SDL_CreateWindow("Hello SDL",
        SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, 640, 480, SDL_WINDOW_SHOWN);
    SDL_Renderer *ren = SDL_CreateRenderer(win, -1, SDL_RENDERER_ACCELERATED);
    SDL_SetRenderDrawColor(ren, 100, 149, 237, 255); // cornflower blue!
    SDL_RenderClear(ren);
    SDL_RenderPresent(ren);
    SDL_Delay(3000);
    SDL_Quit();
    return 0;
}
