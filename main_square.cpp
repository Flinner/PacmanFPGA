#include "Vtop_square.h"
#include <SFML/Graphics.hpp>
#include <iostream>
#include <stdio.h>
#include <verilated.h>

// screen dimensions
const int H_RES = 640;
const int V_RES = 480;

typedef struct Pixel { // for SDL texture
  uint8_t a;           // transparency
  uint8_t b;           // blue
  uint8_t g;           // green
  uint8_t r;           // red
} Pixel;

int main(int argc, char *argv[]) {
  Verilated::commandArgs(argc, argv);

  // Pixel screenbuffer[H_RES * V_RES];

  auto window = sf::RenderWindow({H_RES, V_RES}, "VGA_SIM");
  window.setFramerateLimit(144);
  sf::Event event;
  sf::Texture texture;
  texture.create(H_RES, V_RES);
  // Create a sprite that uses the texture
  sf::Sprite sprite;
  sprite.setTexture(texture);
  sf::Vector2u windowSize = window.getSize();

  // Calculate the scaling factors to stretch the texture to the entire window
  float scaleX = static_cast<float>(windowSize.x) / H_RES;
  float scaleY = static_cast<float>(windowSize.y) / V_RES;

  // Apply the scaling factors to the sprite
  sprite.setScale(scaleX, scaleY);

  // * 4 because pixels have 4 components (RGBA)
  sf::Uint8 *pixels = new sf::Uint8[H_RES * V_RES * 4];

  printf("Simulation running. Press 'Q' in simulation window to quit.\n\n");

  // initialize Verilog module
  Vtop_square *top = new Vtop_square;

  // reset
  top->sim_rst = 1;
  top->clk_pix = 0;
  top->eval();
  top->clk_pix = 1;
  top->eval();
  top->sim_rst = 0;
  top->clk_pix = 0;
  top->eval();

  // initialize frame rate
  // uint64_t start_ticks = SDL_GetPerformanceCounter();
  uint64_t frame_count = 0;

  // main loop
  while (window.isOpen()) {
    // cycle the clock
    top->clk_pix = 1;
    top->eval();
    top->clk_pix = 0;
    top->eval();

    // update pixel if not in blanking interval
    if (top->sdl_de) {
      // Pixel *p = &screenbuffer[top->sdl_sy * H_RES + top->sdl_sx];
      // R, G, B, A
      pixels[(top->sdl_sy * H_RES + top->sdl_sx) * 4 + 0] = top->sdl_r;
      pixels[(top->sdl_sy * H_RES + top->sdl_sx) * 4 + 1] = top->sdl_g;
      pixels[(top->sdl_sy * H_RES + top->sdl_sx) * 4 + 2] = top->sdl_b;
      pixels[(top->sdl_sy * H_RES + top->sdl_sx) * 4 + 3] = 0xFF;
    }

    // update texture once per frame (in blanking)
    if (top->sdl_sy == V_RES && top->sdl_sx == 0) {
      texture.update(pixels);

      while (window.pollEvent(event)) {
        // check the type of the event...
        switch (event.type) {
        // window closed
        case sf::Event::Closed:
          window.close();
          break;
        default:
          break;
        }
      }
      std::cout << "frame:" << frame_count << std::endl;

      // SDL_UpdateTexture(sdl_texture, NULL, screenbuffer, H_RES *
      // sizeof(Pixel)); SDL_RenderClear(sdl_renderer);
      // SDL_RenderCopy(sdl_renderer, sdl_texture, NULL, NULL);
      // SDL_RenderPresent(sdl_renderer);
      window.clear();
      window.draw(sprite);
      window.display();
      frame_count++;
    }
  }

  // calculate frame rate
  // uint64_t end_ticks = SDL_GetPerformanceCounter();
  // double duration =
  //     ((double)(end_ticks - start_ticks)) / SDL_GetPerformanceFrequency();
  // double fps = (double)frame_count / duration;
  // printf("Frames per second: %.1f\n", fps);

  std::cout << "END!\n";
  top->final(); // simulation done

  return 0;
}
