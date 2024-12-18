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

module pacman_movement #(
    parameter INITIAL_MEM_FILE = "NONE",
    localparam H_MAP_WIDTH = params::pacman::H_VISIBLE_AREA,
    localparam V_MAP_HEIGHT = params::pacman::V_VISIBLE_AREA
) (
    input logic vga_pix_clk,
    input logic rst,
    input logic frame_stb,  // 1 stage pipeline
    input logic [$clog2(H_MAP_WIDTH)-1:0] sx,
    input logic [$clog2(V_MAP_HEIGHT)-1:0] sy,
    input logic BTNU,
    input logic BTND,
    input logic BTNR,
    input logic BTNL,
    output logic [8:0] x_pac,
    output logic [8:0] y_pac,
    output logic h_flip,
    v_flip
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
  logic [3:0] MAP_UP;
  logic [3:0] MAP_DOWN;
  logic [3:0] MAP_RIGHT;
  logic [3:0] MAP_LEFT;

  always_comb begin
    /* verilator lint_off WIDTHTRUNC */
    /* verilator lint_on WIDTHTRUNC */
    // 8 is MAP_BLOCK_SIZE
    // this gives the next tile if you moved in the given direction
    MAP_UP    = MAP[x_pac/8+((y_pac-1)/8)*32] ;
    MAP_DOWN  = MAP[x_pac/8+((y_pac)/8)*32+32];
    MAP_RIGHT = MAP[(x_pac)/8 + 1+(y_pac/8)*32];
    MAP_LEFT  = MAP[(x_pac-1)/8+(y_pac/8)*32];
  end

  // if x (the pacman sprite) is perfectly aligned, then moving in y direction will never clip walls
  // perfectly aligned when lower bits are zero...
  logic x_aligned = x_pac[2:0] == '0;
  logic y_aligned = y_pac[2:0] == '0;


  typedef enum {
    UP,
    RIGHT,
    LEFT,
    DOWN
  } direction_t;


  direction_t curr_direction;
  direction_t next_direction;


  always_ff @(posedge vga_pix_clk) begin
    /**/ if (BTNU) next_direction <= UP;
    else if (BTND) next_direction <= DOWN;
    else if (BTNR) next_direction <= RIGHT;
    else if (BTNL) next_direction <= LEFT;
  end

  always_ff @(posedge vga_pix_clk) begin
    case (next_direction)
      UP:    if (MAP_UP   [3] == 1 && x_aligned) curr_direction <= UP;
      DOWN:  if (MAP_DOWN [3] == 1 && x_aligned) curr_direction <= DOWN;
      RIGHT: if (MAP_RIGHT[3] == 1 && y_aligned) curr_direction <= RIGHT;
      LEFT:  if (MAP_LEFT [3] == 1 && y_aligned) curr_direction <= LEFT;
    endcase
    if (rst) curr_direction <= RIGHT;
  end

  always_ff @(posedge vga_pix_clk) begin
    // $display("CLK60HZ: %d, RST: %d", CLK60HZ, rst);
    if (rst) begin
      x_pac <= 8 * 15;
      y_pac <= 8 * 20;
      // $display("x_pac: %d, y_pac: %d", x_pac, y_pac);
    end  // else if (CLK60HZ) begin
    // CLK60HZ is = 1 once per frame thus we add/sub 1 per frame!
    // This avoids an if statment that results in gated clock warning!
    unique case (curr_direction)
      UP:    if (MAP_UP   [3] == 1 && x_aligned) y_pac <= y_pac - {8'b0, CLK60HZ};
      DOWN:  if (MAP_DOWN [3] == 1 && x_aligned) y_pac <= y_pac + {8'b0, CLK60HZ};
      RIGHT: if (MAP_RIGHT[3] == 1 && y_aligned) x_pac <= x_pac + {8'b0, CLK60HZ};
      LEFT:  if (MAP_LEFT [3] == 1 && y_aligned) x_pac <= x_pac - {8'b0, CLK60HZ};
    endcase
    // end
  end

  always_comb begin
    h_flip = 0;
    v_flip = 0;
    if (curr_direction == RIGHT) begin
      h_flip = 1;
      v_flip = 1;
    end else if (curr_direction == LEFT) begin
      h_flip = 0;
      v_flip = 1;
    end else if (curr_direction == UP) begin
      h_flip = 1;
      v_flip = 0;
    end else if (curr_direction == DOWN) begin
      h_flip = 0;
      v_flip = 0;
    end

  end
endmodule : pacman_movement
