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



module drawing_logic #(
    parameter H_VISIBLE_AREA = 640,
    parameter H_FRONT_PORCH  = 16,
    parameter H_SYNC_PULSE   = 96,
    parameter H_BACK_PORCH   = 48,
    parameter V_VISIBLE_AREA = 480,
    parameter V_FRONT_PORCH  = 10,
    parameter V_SYNC_PULSE   = 2,
    parameter V_BACK_PORCH   = 33,

    localparam H_WHOLE_LINE = H_VISIBLE_AREA + H_FRONT_PORCH + H_SYNC_PULSE + H_BACK_PORCH,
    localparam V_WHOLE_LINE = V_VISIBLE_AREA + V_FRONT_PORCH + V_SYNC_PULSE + V_BACK_PORCH,

    localparam H_ADDR_WIDTH = $clog2(H_WHOLE_LINE),
    localparam V_ADDR_WIDTH = $clog2(V_WHOLE_LINE)
) (
    output logic [3:0] R,
    G,
    B,
    input logic vga_pix_clk,
    clk,
    rst,
    frame_stb,
    input logic [H_ADDR_WIDTH-1:0] sx,
    input logic [V_ADDR_WIDTH-1:0] sy,
    input logic display_enabled
);

  logic [$clog2(params::pacman::H_VISIBLE_AREA)-1:0] game_sx;
  logic [$clog2(params::pacman::V_VISIBLE_AREA)-1:0] game_sy;
  logic game_display_enabled;
  logic game_pix_stb;




  display_window_mapper #(  /**AUTOINSTPARAM*/
      // Parameters
      // center the window on the screen
      .H_WINDOW_OFFSET      ((H_VISIBLE_AREA - params::pacman::H_VISIBLE_AREA) / 2),
      .V_WINDOW_OFFSET      ((V_VISIBLE_AREA - params::pacman::V_VISIBLE_AREA) / 2),
      .H_VGA_ADDR_WIDTH     (H_ADDR_WIDTH),
      .V_VGA_ADDR_WIDTH     (V_ADDR_WIDTH),
      .H_WINDOW_VISIBLE_AREA(params::pacman::H_VISIBLE_AREA),
      .V_WINDOW_VISIBLE_AREA(params::pacman::V_VISIBLE_AREA)
  ) pacman_window_mapper (  /*AUTOINST*/
      // Outputs
      .window_sx     (game_sx),
      .window_sy     (game_sy),
      .window_enabled(game_display_enabled),
      .game_pix_stb  (game_pix_stb),
      // Inputs
      .vga_pix_clk   (vga_pix_clk),
      .vga_sx        (sx),
      .vga_sy        (sy)
  );


  // "Modulating" the different colors
  // this alows multiple windows to overlap, or not :)
  logic [3:0] GAME_R, GAME_G, GAME_B;
  logic [3:0] x_debug, y_debug;
  assign x_debug = {4{sx[2:0] == 'b000}};
  assign y_debug = {4{sy[2:0] == 'b000}};


  always_comb
    if (game_display_enabled) begin
      R = GAME_R ^ x_debug;
      G = GAME_G ^ y_debug;
      B = GAME_B;
    end else begin
      R = x_debug;
      G = y_debug;
      B = '0;
    end

  pacman_game pc_game (  /**AUTOINST*/
      // Outputs
      .R(GAME_R),
      .G(GAME_G),
      .B(GAME_B),
      // Inputs
      .game_pix_stb(vga_pix_clk),
      .vga_pix_clk(vga_pix_clk),
      .clk(clk),
      .rst(rst),
      .frame_stb(frame_stb),
      .sx(game_sx),
      .sy(game_sy),
      .display_enabled(game_display_enabled)
  );





endmodule
