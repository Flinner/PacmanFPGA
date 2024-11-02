`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/19/2024 05:37:25 PM
// Design Name: 
// Module Name: drawing_logic
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`include "rtl/params.sv"

// This game only sees 224x288 display. It doesn't care about the rest,
//  it is fine to give random output to save on logic
// The game is 28*36 blocks
module pacman_game #(
    localparam H_MAP_WIDTH = params::pacman::H_VISIBLE_AREA,
    localparam V_MAP_HEIGHT = params::pacman::V_VISIBLE_AREA,
    localparam MAP_F = "rtl/mem/map.mem"
) (
    output logic [3:0] R,
    output logic [3:0] G,
    output logic [3:0] B,
    // there is an important distnction between `vga_pix_clk` and `game_pix_stb`
    // vga_pix_clk will "clock" on each physical vga pixel drawing
    // game_pix_stb will STROBE on each virtual game pixel
    // this is because the game is upscaled/downscaled, and its logic is
    // decoupled from the physical vga display
    input logic vga_pix_clk,
    input logic game_pix_stb,
    input logic clk,
    input logic rst,
    // this strobes on each new frame. i.e, sx==sy==00
    input logic frame_stb,
    input logic [$clog2(H_MAP_WIDTH)-1:0] sx,
    input logic [$clog2(V_MAP_HEIGHT)-1:0] sy,
    input logic display_enabled
);

  logic [1:0] MAP[0:28*36-1];
  initial begin
    $display("Loading MAP from init file '%s'.", MAP_F);
    $readmemb(MAP_F, MAP);
  end


  // TODO: remove useless check, since we check the screen on the RGB anyway
  always_ff @(posedge vga_pix_clk)
    //  STOP ANNOYING ME VERILATOR, I KNOW WHAT I WANT!!!
    /* verilator lint_off WIDTHEXPAND */
    if (game_pix_stb) begin
      R <= {2{MAP[(sx/8)+(sy/8)*28]}};  // TODO: change to 32!!
      G <= 4'h0;
      B <= 4'h0;
      /* verilator lint_on WIDTHEXPAND */
    end else begin
      R <= '0;
      G <= '0;
      B <= '0;
    end

endmodule
