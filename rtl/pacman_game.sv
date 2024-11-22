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
// Additional Comments: This module is pipelined at stage 2,
//                      not that it matters, due to abstraction.
// 
//////////////////////////////////////////////////////////////////////////////////

`ifdef VERILATOR
`include "rtl/params.sv"
`endif

// This game only sees 224x288 display. It doesn't care about the rest,
//  it is fine to give random output to save on logic
// The game is 28*36 blocks
module pacman_game #(
    // MAP PARAMS
    localparam H_MAP_WIDTH = params::pacman::H_VISIBLE_AREA,
    localparam V_MAP_HEIGHT = params::pacman::V_VISIBLE_AREA,
    localparam MAP_BLOCK_SIZE = 8,
    // probably there is a way to make verilator path finding match vivado, not worth the effort to investigate
`ifdef VERILATOR
    localparam MAP_F = "rtl/mem/map.mem",
`else
    localparam MAP_F = "mem/map.mem",
`endif

    // PACMAN PARAMS
    parameter SPRITE_WIDTH  = 8,
    parameter SPRITE_HEIGHT = 8

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
    input logic game_pix_stb,  // 1 stage pipeline
    input logic clk,
    input logic rst,
    // this strobes on each new frame. i.e, sx==sy==00
    input logic frame_stb,  // 1 stage pipeline
    input logic [$clog2(H_MAP_WIDTH)-1:0] sx,  // 1 stage pipeline
    input logic [$clog2(V_MAP_HEIGHT)-1:0] sy,  // 1 stage pipeline
    input logic BTNU,
    input logic BTND,
    input logic BTNR,
    input logic BTNL,
    input logic display_enabled  // 1 stage pipeline
);

  //////////////////////
  // PIPELINING START //
  //////////////////////
  logic [$clog2(H_MAP_WIDTH)-1:0] sx1;
  logic [$clog2(V_MAP_HEIGHT)-1:0] sy1;
  logic display_enabled1;  // 1 stage pipelined
  logic frame_stb1;  // 1 stage pipelined
  logic game_pix_stb1;  // 1 stage pipelined
  always_ff @(posedge vga_pix_clk) begin
    sx1 <= sx;
    sy1 <= sy;
    display_enabled1 <= display_enabled;
    frame_stb1 <= frame_stb;
    game_pix_stb1 <= game_pix_stb;
  end

  ////////////////////
  // PIPELINING END //
  ////////////////////
  logic [8:0] x_pac;
  logic [8:0] y_pac;

  //////////////
  // MOVEMENT //
  //////////////

  pacman_movement #(
      .INITIAL_MEM_FILE(MAP_F)
  ) pacman_movement (  /**AUTOINST*/
      // Outputs
      .x_pac      (x_pac),
      .y_pac      (y_pac),
      // Inputs
      .vga_pix_clk(vga_pix_clk),
      .rst        (rst),
      .frame_stb  (frame_stb1),
      .sx         (sx[$clog2(H_MAP_WIDTH)-1:0]),
      .sy         (sy[$clog2(V_MAP_HEIGHT)-1:0]),
      .BTNU       (BTNU),
      .BTND       (BTND),
      .BTNR       (BTNR),
      .BTNL       (BTNL)
      // .MAP        (MAP  /*[3:0].[0:32*36-1]*/)
  );

  ////////////////////////////
  // CANDY and POWER COOKIE //
  ////////////////////////////


  // this is the drawing beam's map tile
  logic [3:0] map_drawing_tile;
  // this is pacman's map tile
  logic [3:0] map_pacman_tile;

  // strobe when eating a (power)cookie for one vga_pix_clk
  logic ate_candy_stb;
  logic ate_power_cookie_stb;


  always_ff @(posedge vga_pix_clk) begin
    if (frame_stb1) begin
      ate_candy_stb <= map_pacman_tile == 'b1001;
      ate_power_cookie_stb <= map_pacman_tile == 'b1010;
      $display("map_pacman_tile: %b", map_pacman_tile);
      $display("CANDY: %b, POWER: %b", ate_candy_stb, ate_power_cookie_stb);
    end
  end

  dual_port_bram #(
      // Parameters
      .DATA_WIDTH(4),
      .DATA_DEPTH(32 * 36),
      .INITIAL_MEM_FILE(MAP_F)
  ) candy_and_map_memory (
      // Outputs
      .douta(map_drawing_tile),
      .doutb(map_pacman_tile),
      // Inputs
      .clk  (vga_pix_clk),
      .wea  ('0),
      .web  (ate_candy_stb | ate_power_cookie_stb),
      /* verilator lint_off WIDTHEXPAND */
      // PIPELINE - 1: this returns data one clk later
      .addra((sx / 8) + (sy / 8) * 32),
      // I think x_pac doesn't need the -1 pipeline
      // I believe this is fine, since x_pac/y_pac change values at new frames
      // by the time they change 100s of clks has passed
      .addrb((x_pac / 8) + (y_pac / 8) * 32),
      /* verilator lint_on WIDTHEXPAND */
      .dia  ('b0),
      .dib  ('b1000)
  );


  ////////////////////////
  // SPRITES AND COLORS //
  ////////////////////////

  // PACMAN COLOR
  logic [11:0] color;
  logic [3:0] R_PAC;
  logic [3:0] G_PAC;
  logic [3:0] B_PAC;

  logic pixel_in_sprite;

  assign color = 12'hFFF;
  always_comb begin
    pixel_in_sprite = (({1'b0,sx1} >= x_pac && {1'b0,sx1} < x_pac + SPRITE_WIDTH) &&
                       (sy1 >= y_pac && sy1 < y_pac + SPRITE_HEIGHT));

    if (pixel_in_sprite) begin
      R_PAC = color[11:8];
      G_PAC = color[7:4];
      B_PAC = color[3:0];
    end else begin
      //square = (sx1 >= x1_pac && sx1<x2_pac) && (sy1 >= y1 && sy1< y2);
      R_PAC = 4'h0;  // Default red component
      G_PAC = 4'h0;  // Default green component
      B_PAC = 4'h0;  // Default blue component
    end
  end





  // THIS IS TEMPORARY!!!!!
  logic [3:0] RRRR;
  logic [3:0] GGGG;
  logic [3:0] BBBB;

  sprite_map sprite_map (
      sx[2:0],
      sy[2:0],
      map_drawing_tile,
      RRRR,
      GGGG,
      BBBB
  );

  // TODO: remove useless check, since we check the screen on the RGB anyway
  always_comb begin
    // if (game_pix_stb1) begin
    R = RRRR | R_PAC;  // TODO: change to 32!!
    G = GGGG | G_PAC;
    B = BBBB | B_PAC;
    // end else begin
    //   R <= '0;
    //   G <= '0;
    //   B <= '0;
  end

endmodule
