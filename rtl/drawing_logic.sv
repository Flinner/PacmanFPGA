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

`ifdef VERILATOR
`include "rtl/common_defines.svh"
`include "rtl/params.sv"
`else
`include "common_defines.svh"
`endif



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
    output sound_t sound_type,
    input logic vga_pix_clk,
    input logic clk,
    input logic rst,
    input logic frame_stb,  // 1 stage pipelined
    input logic [H_ADDR_WIDTH-1:0] sx,  // 1 stage pipelined
    input logic [V_ADDR_WIDTH-1:0] sy,  // 1 stage pipelined
    input logic display_enabled,  // 1 stage pipelined
    input logic BTNU,
    input logic BTND,
    input logic BTNR,
    input logic BTNL
);

  //////////////////////
  // PIPELINING START //
  //////////////////////
  logic [H_ADDR_WIDTH-1:0] sx1;  // 1 stage pipelined
  logic [V_ADDR_WIDTH-1:0] sy1;  // 1 stage pipelined
  logic display_enabled1;  // 1 stage pipelined
  logic frame_stb1;  // 1 stage pipelined
  always_ff @(posedge vga_pix_clk) begin
    sx1 <= sx;
    sy1 <= sy;
    display_enabled1 <= display_enabled;
    frame_stb1 <= frame_stb;
  end
  ////////////////////
  // PIPELINING END //
  ////////////////////



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
  ) pacman_window_mapper (  /**AUTOINST*/
      // Outputs
      .window_sx     (game_sx),
      .window_sy     (game_sy),
      .window_enabled(game_display_enabled),
      .game_pix_stb  (game_pix_stb),
      // Inputs
      .vga_pix_clk   (vga_pix_clk),
      .vga_sx        (sx1),
      .vga_sy        (sy1)
  );


  // "Modulating" the different colors
  // this alows multiple windows to overlap, or not :)
  logic [3:0] GAME_R, GAME_G, GAME_B;
  logic [3:0] x_debug, y_debug;
  assign x_debug = {4{sx1[2:0] == 'b000}};
  assign y_debug = {4{sy1[2:0] == 'b000}};


  always_comb
    if (game_display_enabled) begin
      R = GAME_R;
      G = GAME_G;  //| y_debug;
      B = GAME_B;  //| x_debug;
    end else begin
      R = '0;
      G = '0;  //y_debug;
      B = '0;  //x_debug;
    end

  pacman_game pc_game (  /**AUTOINST*/
      // Outputs
      .R(GAME_R),
      .G(GAME_G),
      .B(GAME_B),
      .sound_type(sound_type),
      // Inputs
      .game_pix_stb(vga_pix_clk),
      .vga_pix_clk(vga_pix_clk),
      .clk(clk),
      .rst(rst),
      .frame_stb(frame_stb1),
      .sx(game_sx),
      .sy(game_sy),
      .BTNU(BTNU),
      .BTND(BTND),
      .BTNR(BTNR),
      .BTNL(BTNL),
      .display_enabled(game_display_enabled)
  );





endmodule
