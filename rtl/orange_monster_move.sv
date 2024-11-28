`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/24/2024 03:56:32 PM
// Design Name: 
// Module Name: orange_monster_mov
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

module orange_monster_move #(
    parameter INITIAL_MEM_FILE = "NONE",
    localparam H_MAP_WIDTH = params::pacman::H_VISIBLE_AREA,
    localparam V_MAP_HEIGHT = params::pacman::V_VISIBLE_AREA
) (
    input logic vga_pix_clk,
    input logic rst,
    input logic frame_stb,    // 1 stage pipeline

    input  logic [8:0] x_pac,
    input  logic [8:0] y_pac,
    output logic [8:0] x_orange,
    output logic [8:0] y_orange
);

  logic CLK60HZ;
  assign CLK60HZ = frame_stb;

  ///////////////////////
  // MAP DRAWING LOGIC //
  ///////////////////////
  // TODO: Optimize this, MAP can be 1 bit wide. We only check MAP[3].
  logic [3:0] MAP[0:32*36-1];
  initial begin
    $display("Loading MAP from init file '%s'.", INITIAL_MEM_FILE);
    $readmemb(INITIAL_MEM_FILE, MAP);
  end


  // will hit if kept moving up...
  logic [3:0] MAP_UP_ORANGE;
  logic [3:0] MAP_DOWN_ORANGE;
  logic [3:0] MAP_RIGHT_ORANGE;
  logic [3:0] MAP_LEFT_ORANGE;

  always_comb begin
    /* verilator lint_off WIDTHTRUNC */
    /* verilator lint_on WIDTHTRUNC */
    // 8 is MAP_BLOCK_SIZE
    // this gives the next tile if you moved in the given direction
    MAP_UP_ORANGE    = MAP[x_orange/8+((y_orange-1)/8)*32] ;
    MAP_DOWN_ORANGE  = MAP[x_orange/8+((y_orange)/8)*32+32];
    MAP_RIGHT_ORANGE = MAP[(x_orange)/8 + 1+(y_orange/8)*32];
    MAP_LEFT_ORANGE  = MAP[(x_orange-1)/8+(y_orange/8)*32];
  end

  // if x (the pacman sprite) is perfectly aligned, then moving in y direction will never clip walls
  // perfectly aligned when lower bits are zero...
  logic x_aligned = x_orange[2:0] == '0;
  logic y_aligned = y_orange[2:0] == '0;


  typedef enum {
    UP,
    RIGHT,
    LEFT,
    DOWN
  } direction_t;


  direction_t curr_direction;
  direction_t next_direction;


  always_ff @(posedge vga_pix_clk) begin
    if (y_pac < y_orange) next_direction <= UP;
    if (y_pac > y_orange) next_direction <= DOWN;
    if (x_pac > x_orange) next_direction <= RIGHT;
    if (x_pac < x_orange) next_direction <= LEFT;
  end


  always_ff @(posedge vga_pix_clk) begin
    case (next_direction)
      UP:    if (MAP_UP_ORANGE[3] == 1 && x_aligned) curr_direction <= UP;
      DOWN:  if (MAP_DOWN_ORANGE[3] == 1 && x_aligned) curr_direction <= DOWN;
      RIGHT: if (MAP_RIGHT_ORANGE[3] == 1 && y_aligned) curr_direction <= RIGHT;
      LEFT:  if (MAP_LEFT_ORANGE[3] == 1 && y_aligned) curr_direction <= LEFT;
    endcase
    if (rst) curr_direction <= RIGHT;
  end

  always_ff @(posedge vga_pix_clk) begin
    // $display("CLK60HZ: %d, RST: %d", CLK60HZ, rst);
    if (rst) begin
      x_orange <= 8 * 15;
      y_orange <= 8 * (4 + 10);
      // $display("x_pac: %d, y_pac: %d", x_pac, y_pac);
    end  // else if (CLK60HZ) begin
    // CLK60HZ is = 1 once per frame thus we add/sub 1 per frame!
    // This avoids an if statment that results in gated clock warning!
    unique case (curr_direction)
      UP:    if (MAP_UP_ORANGE[3] == 1 && x_aligned) y_orange <= y_orange - {8'b0, CLK60HZ};
      DOWN:  if (MAP_DOWN_ORANGE[3] == 1 && x_aligned) y_orange <= y_orange + {8'b0, CLK60HZ};
      RIGHT: if (MAP_RIGHT_ORANGE[3] == 1 && y_aligned) x_orange <= x_orange + {8'b0, CLK60HZ};
      LEFT:  if (MAP_LEFT_ORANGE[3] == 1 && y_aligned) x_orange <= x_orange - {8'b0, CLK60HZ};
    endcase
    // end
  end
endmodule : orange_monster_move
