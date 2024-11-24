`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/24/2024 10:33:48 AM
// Design Name: 
// Module Name: pacman_sprite
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


module pacman_sprite(

    input logic clk,rst,
    input logic [8:0] x_pac,
    input logic [8:0] y_pac,
   
    input logic [7:0] sx,
    input logic [8:0] sy,

    output logic [3:0] R,
    output logic [3:0] G,
    output logic [3:0] B
);

  localparam SPRITE_WIDTH = 8;
  localparam SPRITE_HEIGHT = 8;


  logic pixel_in_red_sprite;

  logic [3:0] R_PAC;
  logic [3:0] G_PAC;
  logic [3:0] B_PAC;
  
  
  logic pixel_in_pacman_sprite;
  logic [6:0] pacman_address;
  logic [11:0] color;
  //assign color = 12'hFFF;
  sprite_of_pacman sp_pacman(.clka(clk),.addra(pacman_address),.douta(color));
  always_comb begin
    pixel_in_pacman_sprite = (({1'b0,sx} >= x_pac && {1'b0,sx} < x_pac + SPRITE_WIDTH) &&
                       (sy >= y_pac && sy < y_pac + SPRITE_HEIGHT));

    if (pixel_in_pacman_sprite) begin
      pacman_address = (sy - y_pac) * SPRITE_WIDTH + (sx - x_pac);
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


  assign R = R_PAC;
  assign G = G_PAC;
  assign B = B_PAC;


endmodule : pacman_sprite

