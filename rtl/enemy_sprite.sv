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

module enemy_sprite (
    input logic clk,
    input logic rst,
    input logic [8:0] x_red,
    input logic [8:0] y_red,
    input logic [8:0] x_blue,
    input logic [8:0] y_blue,
    input logic [8:0] x_yellow,
    input logic [8:0] y_yellow,
    input logic [8:0] x_pink,
    input logic [8:0] y_pink,
    input logic [7:0] sx,
    input logic [8:0] sy,

    output logic [3:0] R,
    output logic [3:0] G,
    output logic [3:0] B
);

  localparam SPRITE_WIDTH = 8;
  localparam SPRITE_HEIGHT = 8;
  localparam MONSTER_WIDTH = 8;
  localparam MONSTER_HEIGHT = 8;

  logic pixel_in_red_sprite, pixel_in_pink_sprite, pixel_in_blue_sprite;
  logic [11:0] R_color, P_color, B_color;
  logic [5:0] red_address, pink_address, blue_address;

  rams_dist #(
`ifdef VERILATOR
      .INITIAL_MEM_FILE("rtl/mem/red_monster_sprite.mem"),
`else
      .INITIAL_MEM_FILE("../mem/red_monster_sprite.mem"),
`endif
      .DATA_WIDTH(12),
      .DATA_DEPTH(64)
  ) red_sprite (
      .a  (red_address),
      .spo(R_color)
  );

  rams_dist #(
`ifdef VERILATOR
      .INITIAL_MEM_FILE("rtl/mem/pink_monster_sprite.mem"),
`else
      .INITIAL_MEM_FILE("../mem/pink_monster_sprite.mem"),
`endif
      .DATA_WIDTH(12),
      .DATA_DEPTH(64)
  ) pink_sprite (
      .a  (pink_address),
      .spo(P_color)
  );

  rams_dist #(
`ifdef VERILATOR
      .INITIAL_MEM_FILE("rtl/mem/blue_monster_sprite.mem"),
`else
      .INITIAL_MEM_FILE("../mem/blue_monster_sprite.mem"),
`endif
      .DATA_WIDTH(12),
      .DATA_DEPTH(64)
  ) blue_sprite (
      .a  (blue_address),
      .spo(B_color)
  );


  /* verilator lint_off WIDTHTRUNC */
  always_comb begin
    pixel_in_red_sprite = (({1'b0,sx} >= x_red && {1'b0,sx} < x_red + SPRITE_WIDTH) &&
                       (sy >= y_red && sy < y_red + SPRITE_HEIGHT));

    pixel_in_pink_sprite = (({1'b0,sx} >= x_pink && {1'b0,sx} < x_pink + SPRITE_WIDTH) &&
                       (sy >= y_pink && sy < y_pink + SPRITE_HEIGHT));

    pixel_in_blue_sprite = (({1'b0,sx} >= x_blue && {1'b0,sx} < x_blue + SPRITE_WIDTH) &&
                       (sy >= y_blue && sy < y_blue + SPRITE_HEIGHT));


    red_address = {1'b0, sx} - x_red + (sy - y_red) * MONSTER_WIDTH;
    pink_address = {1'b0, sx} - x_pink + (sy - y_pink) * MONSTER_WIDTH;
    blue_address = {1'b0, sx} - x_blue + (sy - y_blue) * MONSTER_WIDTH;
    if (pixel_in_red_sprite) begin
      R = R_color[11:8];
      G = R_color[7:4];
      B = R_color[3:0];
    end else if (pixel_in_pink_sprite) begin
      R = P_color[11:8];
      G = P_color[7:4];
      B = P_color[3:0];
    end else if (pixel_in_blue_sprite) begin
      R = B_color[11:8];
      G = B_color[7:4];
      B = B_color[3:0];
    end else begin
      R = 4'h0;  // Default red component
      G = 4'h0;  // Default green component
      B = 4'h0;  // Default blue component
    end
  end
  /* verilator lint_on WIDTHTRUNC */

endmodule : enemy_sprite
