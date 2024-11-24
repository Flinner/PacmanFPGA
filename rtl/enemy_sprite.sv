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
    input logic clk,rst,
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
  localparam MONSTER_WIDTH = 14;
  localparam MONSTER_HEIGHT = 14;

  logic pixel_in_red_sprite, pixel_in_pink_sprite,pixel_in_cyan_sprite;
  logic [11:0] R_color, P_color, C_color;
  assign R_color = 12'hE11;
  assign P_color = 12'HFCD;
  assign C_color = 12'h0FF;

  logic [3:0] R_red, R_pink, R_cyan;
  logic [3:0] G_red, G_pink, G_cyan;
  logic [3:0] B_red, B_pink, B_cyan;
  
  logic [11:0] red_color, pink_color, cyan_color;
  logic [8:0] red_address, pink_address, cyan_address;
  
  //blk_mem_gen_0_ red_monster (.clka(clk),.addra(red_address),.douta(red_color));
  always_comb begin
    pixel_in_red_sprite = (({1'b0,sx} >= x_red && {1'b0,sx} < x_red + SPRITE_WIDTH) &&
                       (sy >= y_red && sy < y_red + SPRITE_HEIGHT));
    
    pixel_in_pink_sprite = (({1'b0,sx} >= x_pink && {1'b0,sx} < x_pink + SPRITE_WIDTH) &&
                       (sy >= y_pink && sy < y_pink + SPRITE_HEIGHT));
                       
    pixel_in_cyan_sprite = (({1'b0,sx} >= x_blue && {1'b0,sx} < x_blue + SPRITE_WIDTH) &&
                       (sy >= y_blue && sy < y_blue + SPRITE_HEIGHT));

    if (pixel_in_red_sprite) begin
     // red_address = {1'b0,sx}-x_red + (sy-y_red) * MONSTER_WIDTH;
      R = R_color[11:8];
      G = R_color[7:4];
      B = R_color[3:0];
    end else if (pixel_in_pink_sprite) begin
     // red_address = {1'b0,sx}-x_red + (sy-y_red) * MONSTER_WIDTH;
      R = P_color[11:8];
      G = P_color[7:4];
      B = P_color[3:0];
    end else if (pixel_in_cyan_sprite) begin
     // red_address = {1'b0,sx}-x_red + (sy-y_red) * MONSTER_WIDTH;
      R = C_color[11:8];
      G = C_color[7:4];
      B = C_color[3:0];
    end
    
     else begin
      //square = (sx1 >= x1_pac && sx1<x2_pac) && (sy1 >= y1 && sy1< y2);
      R = 4'h0;  // Default red component
      G = 4'h0;  // Default green component
      B = 4'h0;  // Default blue component
    end
  end


 // assign R = R_red;
  //assign G = G_red;
  //assign B = B_red;


endmodule : enemy_sprite
