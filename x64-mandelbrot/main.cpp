#include <SDL2/SDL.h>
#include <iostream>
#include <stdio.h>
#include <string>
#include "mandelbrot.h"

void redrawWindow(SDL_Texture* texture, SDL_Renderer* renderer, int width, Uint32* pixels) {
    // Update the texture with the pixel buffer
    SDL_UpdateTexture(texture, nullptr, pixels, width * sizeof(Uint32));

    // Clear the renderer and copy the texture to the renderer
    SDL_RenderClear(renderer);
    SDL_RenderCopy(renderer, texture, nullptr, nullptr);
    SDL_RenderPresent(renderer);
}

int max(int a, int b) {
    if (a > b) {
        return a;
    }
    return b;
}


int main(int argc, char *argv[]) {
    int WIDTH = 1250;
    int HEIGHT = 1250;

    if (argc == 3) {
        WIDTH = std::stoi(argv[1]);
        HEIGHT = std::stoi(argv[2]);
    }

    const double SCALE = 1;
    double scale = 1;   // 0 - 20
    double move_right = 0;
    double move_up = 0;


    // Initialize SDL
    if (SDL_Init(SDL_INIT_VIDEO) != 0) {
        std::cerr << "Failed to initialize SDL: " << SDL_GetError() << std::endl;
        return 1;
    }

    // Create a window
    SDL_Window* window = SDL_CreateWindow("Mandelbrot Set", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, WIDTH, HEIGHT, SDL_WINDOW_SHOWN);
    if (window == nullptr) {
        std::cerr << "Failed to create SDL window: " << SDL_GetError() << std::endl;
        SDL_Quit();
        return 1;
    }

    // Create a renderer
    SDL_Renderer* renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);
    if (renderer == nullptr) {
        std::cerr << "Failed to create SDL renderer: " << SDL_GetError() << std::endl;
        SDL_DestroyWindow(window);
        SDL_Quit();
        return 1;
    }

    // Create a texture
    SDL_Texture* texture = SDL_CreateTexture(renderer, SDL_PIXELFORMAT_ARGB8888, SDL_TEXTUREACCESS_STATIC, WIDTH, HEIGHT);
    if (texture == nullptr) {
        std::cerr << "Failed to create SDL texture: " << SDL_GetError() << std::endl;
        SDL_DestroyRenderer(renderer);
        SDL_DestroyWindow(window);
        SDL_Quit();
        return 1;
    }

    // Create a pixel buffer
    Uint32* pixels = new Uint32[WIDTH * HEIGHT];

    // Fill the pixel buffer
    mandelbrot(pixels, WIDTH, HEIGHT, SCALE);


    // Update the texture with the pixel buffer
    SDL_UpdateTexture(texture, nullptr, pixels, WIDTH * sizeof(Uint32));

    // Clear the renderer and copy the texture to the renderer
    SDL_RenderClear(renderer);
    SDL_RenderCopy(renderer, texture, nullptr, nullptr);
    SDL_RenderPresent(renderer);

    // Wait for user input
    bool quit = false;
    Uint32 previousKeyUpTime = SDL_GetTicks();
    SDL_Event event;
    while (!quit) {
        while (SDL_PollEvent(&event)) {
            if (event.type == SDL_QUIT) {
                quit = true;
            }
            else if (event.type == SDL_WINDOWEVENT && event.window.event == SDL_WINDOWEVENT_RESIZED) {
                // Window has been resized, reset the window size
                SDL_SetWindowSize(window, WIDTH, HEIGHT);
            }
            else if (event.type == SDL_KEYUP) {
                Uint32 currentTicks = SDL_GetTicks();
                if (event.key.keysym.sym == SDLK_BACKSPACE) {
                    mandelbrot(pixels, WIDTH, HEIGHT, SCALE);
                    redrawWindow(texture, renderer, WIDTH, pixels);
                    scale = SCALE;
                    move_right = 0;
                    move_up = 0;
                }
                else if (event.key.keysym.sym == SDLK_d) {
                    move_right += 0.1*scale;
                    mandelbrot(pixels, WIDTH, HEIGHT, scale, move_right, move_up);
                    redrawWindow(texture, renderer, WIDTH, pixels);
                }
                else if (event.key.keysym.sym == SDLK_a) {
                    move_right -= 0.1*scale;
                    mandelbrot(pixels, WIDTH, HEIGHT, scale, move_right, move_up);
                    redrawWindow(texture, renderer, WIDTH, pixels);
                }
                else if (event.key.keysym.sym == SDLK_w) {
                    move_up -= 0.1*scale;
                    mandelbrot(pixels, WIDTH, HEIGHT, scale, move_right, move_up);
                    redrawWindow(texture, renderer, WIDTH, pixels);
                }
                else if (event.key.keysym.sym == SDLK_s) {
                    move_up += 0.1*scale;
                    mandelbrot(pixels, WIDTH, HEIGHT, scale, move_right, move_up);
                    redrawWindow(texture, renderer, WIDTH, pixels);
                }
                else if (currentTicks - previousKeyUpTime >= 500) {
                    if (event.key.keysym.sym == SDLK_UP) {
                        scale = scale * 2;
                        mandelbrot(pixels, WIDTH, HEIGHT, scale, move_right, move_up);
                        redrawWindow(texture, renderer, WIDTH, pixels);
                        previousKeyUpTime = currentTicks;
                    }
                    else if (event.key.keysym.sym == SDLK_DOWN) {
                        scale = scale / 2;
                        mandelbrot(pixels, WIDTH, HEIGHT, scale, move_right, move_up);
                        redrawWindow(texture, renderer, WIDTH, pixels);
                        previousKeyUpTime = currentTicks;
                    }
                }
            }
        }
    }

    // Clean up resources
    delete[] pixels;
    SDL_DestroyTexture(texture);
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();

    return 0;
}
