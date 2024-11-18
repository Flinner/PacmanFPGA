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
    input logic game_pix_stb,
    input logic clk,
    input logic rst,
    // this strobes on each new frame. i.e, sx==sy==00
    input logic frame_stb,
    input logic [$clog2(H_MAP_WIDTH)-1:0] sx,
    input logic [$clog2(V_MAP_HEIGHT)-1:0] sy,
    input logic BTNU,
    input logic BTND,
    input logic BTNR,
    input logic BTNL,
    input logic display_enabled
);

  logic CLK60HZ;
  assign CLK60HZ = frame_stb;

  ///////////////////////
  // PACMAN USER LOGIC //
  ///////////////////////
  logic [8:0] x_pac;
  logic [8:0] y_pac;
  // PACMAN COLOR
  logic [11:0] color;
  logic [3:0] R_PAC;
  logic [3:0] G_PAC;
  logic [3:0] B_PAC;



  logic pixel_in_sprite;
  logic [10:0] pixel_index;
  assign color = 12'hFFF;

  // will hit if kept moving up...
  logic MAP_UP;
  logic MAP_DOWN;
  logic MAP_RIGHT;
  logic MAP_LEFT;

  always_ff @(posedge vga_pix_clk) begin
    /* verilator lint_off WIDTHTRUNC */
    /* verilator lint_on WIDTHTRUNC */
    // 8 is MAP_BLOCK_SIZE
    // this gives the next tile if you moved in the given direction
    MAP_UP    <= MAP[x_pac/8+((y_pac-1)/8)*32] != 0;
    MAP_DOWN  <= MAP[x_pac/8+((y_pac)/8)*32+32] != 0 && MAP[(x_pac)/8+((y_pac)/8)*32+32] != 0;
    MAP_RIGHT <= MAP[(x_pac)/8 + 1+(y_pac/8)*32] != 0;
    MAP_LEFT  <= MAP[(x_pac-1)/8+(y_pac/8)*32] != 0;
  end



  always_ff @(posedge vga_pix_clk) begin
    if (CLK60HZ) begin
      if (rst) begin
        x_pac <= 8 * 3;
        y_pac <= 8;
      end else begin
        /* verilator lint_off WIDTHEXPAND */
        if (BTNU && MAP_UP == 0) begin
          /* verilator lint_on WIDTHEXPAND */
          y_pac <= y_pac - 1;
          // v_flip <= 0;
        end
        if (BTND && MAP_DOWN == 0) begin
          y_pac <= y_pac + 1'b1;
          // v_flip <= 1;
        end
        if (BTNR && MAP_RIGHT == 0) begin
          x_pac <= x_pac + 1'b1;
          // h_flip <= 0;
        end
        if (BTNL && MAP_LEFT == 0) begin
          x_pac <= x_pac - 1'b1;
          // h_flip <= 1;
        end
      end
    end
  end


  always_comb begin
    pixel_in_sprite = (({1'b0,sx} >= x_pac && {1'b0,sx} < x_pac + SPRITE_WIDTH) &&
                       (sy >= y_pac && sy < y_pac + SPRITE_HEIGHT));

    if (pixel_in_sprite) begin
      R_PAC = color[11:8];
      G_PAC = color[7:4];
      B_PAC = color[3:0];
    end else begin
      //square = (sx >= x1_pac && sx<x2_pac) && (sy >= y1 && sy< y2);
      R_PAC = 4'h0;  // Default red component
      G_PAC = 4'h0;  // Default green component
      B_PAC = 4'h0;  // Default blue component
    end
  end


  ///////////////////////
  // MAP DRAWING LOGIC //
  ///////////////////////
  logic [2:0] MAP[0:32*36-1];
  initial begin
    $display("Loading MAP from init file '%s'.", MAP_F);
    $readmemb(MAP_F, MAP);
  end


  logic [2:0] map_location;
  assign map_location = MAP[(sx/8)+(sy/8)*32];

  // TODO: remove useless check, since we check the screen on the RGB anyway
  always_comb begin
    //  STOP ANNOYING ME VERILATOR, I KNOW WHAT I WANT!!!
    /* verilator lint_off WIDTHEXPAND */
    // if (game_pix_stb) begin
    R = {map_location, 1'b0} | R_PAC;  // TODO: change to 32!!
    G = 4'h0 | G_PAC;
    B = 4'h0 | B_PAC;
    /* verilator lint_on WIDTHEXPAND */
    // end else begin
    //   R <= '0;
    //   G <= '0;
    //   B <= '0;
  end

endmodule
