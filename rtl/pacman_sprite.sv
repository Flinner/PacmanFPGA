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


module pacman_sprite (

    input logic clk,
    rst,
    input logic [8:0] x_pac,
    input logic [8:0] y_pac,

    input logic [7:0] sx,
    input logic [8:0] sy,

    input logic h_flip,
    input logic v_flip,

    output logic [3:0] R,
    output logic [3:0] G,
    output logic [3:0] B
);

  localparam SPRITE_WIDTH = 8;
  localparam SPRITE_HEIGHT = 8;


  logic pixel_in_red_sprite;

  logic pixel_in_pacman_sprite;
  logic [5:0] pacman_address, pacman_address1;
  logic [11:0] color, color0, color1;
  //assign color = 12'hFFF;
  rams_dist #(
`ifdef VERILATOR
      .INITIAL_MEM_FILE("rtl/mem/open_mouth_8.mem"),
`else
      .INITIAL_MEM_FILE("../mem/open_mouth_8.mem"),
`endif
      .DATA_WIDTH(8),
      .DATA_DEPTH(64)
  ) pacmanSprite (
      .a  (pacman_address),
      .spo(color0)
  );
  rams_dist #(
`ifdef VERILATOR
      .INITIAL_MEM_FILE("rtl/mem/closed_mouth_8.mem"),
`else
      .INITIAL_MEM_FILE("../mem/closed_mouth_8.mem"),
`endif
      .DATA_WIDTH(12),
      .DATA_DEPTH(64)
  ) pacmanSprite_closed (
      .a  (pacman_address1),
      .spo(color1)
  );
  logic toggle, stb;

  precise_div tog (
      .i_clk  (clk),
      .i_reset(rst),
      .o_stb  (stb)
  );
  always_comb begin
    pixel_in_pacman_sprite = (({1'b0,sx} >= x_pac && {1'b0,sx} < x_pac + SPRITE_WIDTH) &&
                       (sy >= y_pac && sy < y_pac + SPRITE_HEIGHT));

    pacman_address = '0;
    if (stb) toggle <= ~toggle;

    /* verilator lint_off WIDTHTRUNC */
    if (pixel_in_pacman_sprite) begin
      if (h_flip == 1 && v_flip == 1) begin
        pacman_address  = (sy - y_pac) * SPRITE_WIDTH + (sx - x_pac);
        pacman_address1 = (sy - y_pac) * SPRITE_WIDTH + (sx - x_pac);
      end else if (h_flip == 0 && v_flip == 1) begin
        pacman_address  = (sy - y_pac) * SPRITE_WIDTH + SPRITE_HEIGHT - 1 - (sx - x_pac);
        pacman_address1 = (sy - y_pac) * SPRITE_WIDTH + SPRITE_HEIGHT - 1 - (sx - x_pac);
      end else if (h_flip == 1 && v_flip == 0) begin
        pacman_address  = (sx - x_pac) * SPRITE_WIDTH + (SPRITE_HEIGHT - 1 - (sy - y_pac));
        pacman_address1 = (sx - x_pac) * SPRITE_WIDTH + (SPRITE_HEIGHT - 1 - (sy - y_pac));
      end else if (h_flip == 0 && v_flip == 0) begin
        pacman_address  = (SPRITE_WIDTH - 1 - (sx - x_pac)) * SPRITE_WIDTH + (sy - y_pac);
        pacman_address1 = (SPRITE_WIDTH - 1 - (sx - x_pac)) * SPRITE_WIDTH + (sy - y_pac);
      end

      color = (toggle) ? color0 : color1;
      R = color[11:8];
      G = color[7:4];
      B = color[3:0];

    end else begin
      R = 4'b0000;
      G = 4'b0000;
      B = 4'b0000;
    end

  end
  /* verilator lint_on WIDTHTRUNC */
endmodule : pacman_sprite

