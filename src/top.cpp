#include "Vtop.h"
#include <SFML/Graphics.hpp>
#include <SFML/Window/Event.hpp>
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

  // Clock to measure fps
  sf::Clock clock;

  // Calculate the scaling factors to stretch the texture to the entire window
  float scaleX = static_cast<float>(windowSize.x) / H_RES;
  float scaleY = static_cast<float>(windowSize.y) / V_RES;

  // Apply the scaling factors to the sprite
  sprite.setScale(scaleX, scaleY);

  // * 4 because pixels have 4 components (RGBA)
  sf::Uint8 *pixels = new sf::Uint8[H_RES * V_RES * 4];

  printf("Simulation running. Press 'Q' in simulation window to quit.\n\n");

  // initialize Verilog module
  Vtop *top = new Vtop;

  // reset 10 times just in case my pipelining fucks things up...
  for (int i = 0; i < 10; i++) {
    top->CPU_RESETN = 0;
    top->CLK100MHZ = 0;
    top->eval();
    top->CLK100MHZ = 1;
    top->eval();
  }
  top->CPU_RESETN = 1;
  top->CLK100MHZ = 0;
  top->eval();

  uint64_t frame_count = 0;

  // main loop
  while (window.isOpen()) {
    // cycle the clock
    top->CLK100MHZ = 1;
    top->eval();
    top->CLK100MHZ = 0;
    top->eval();

    // update pixel if not in blanking interval
    if (top->display_enabled) {
      // R, G, B, A
      // << 4 because in .sv it is [3:0], while pixel is expected to be Uint8
      pixels[(top->sy * H_RES + top->sx) * 4 + 0] = top->VGA_R << 4;
      pixels[(top->sy * H_RES + top->sx) * 4 + 1] = top->VGA_G << 4;
      pixels[(top->sy * H_RES + top->sx) * 4 + 2] = top->VGA_B << 4;
      pixels[(top->sy * H_RES + top->sx) * 4 + 3] = 0xFF;
      ;
    }

    // update texture once per frame (in blanking)
    if (top->sy == V_RES && top->sx == 0) {
      texture.update(pixels);

      while (window.pollEvent(event)) {
        // check the type of the event...
        switch (event.type) {
        // window closed
        case sf::Event::Closed:
          window.close();
          break;
        // Key pressed
        case sf::Event::KeyPressed:
          top->BTNU = 0;
          top->BTNR = 0;
          top->BTNL = 0;
          top->BTND = 0;
          if (sf::Keyboard::isKeyPressed(sf::Keyboard::W)) {
            top->BTNU = 1;
            std::cout << "W key pressed\n";
          }
          if (sf::Keyboard::isKeyPressed(sf::Keyboard::A)) {
            top->BTNL = 1;
            std::cout << "A key pressed\n";
          }
          if (sf::Keyboard::isKeyPressed(sf::Keyboard::S)) {
            top->BTND = 1;
            std::cout << "S key pressed\n";
          }
          if (sf::Keyboard::isKeyPressed(sf::Keyboard::D)) {
            top->BTNR = 1;
            std::cout << "D key pressed\n";
          }

          break;
        default:
          break;
        }
      }
      std::cout << "frame:" << frame_count << std::endl;

      window.clear();
      window.draw(sprite);
      window.display();
      frame_count++;
    }
  }

  // Calculate the total elapsed time in seconds
  float elapsedTime = clock.getElapsedTime().asSeconds();

  // Calculate and print the average frame rate (FPS)
  if (elapsedTime > 0) {
    float fps = frame_count / elapsedTime;
    std::cout << "Average FPS: " << fps << std::endl;
  }

  std::cout << "END!\n";
  top->final(); // simulation done

  return 0;
}
