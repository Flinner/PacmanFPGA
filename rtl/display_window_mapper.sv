`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/02/2024 05:37:25 PM
// Design Name: 
// Module Name: display_window_mapper
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

module display_window_mapper #(
    parameter H_WINDOW_OFFSET = 20,
    parameter V_WINDOW_OFFSET = 20,

    // TODO: Clean these comments
    // parameter H_VGA_VISIBLE_AREA = 100,
    // parameter V_VGA_VISIBLE_AREA = 100,
    parameter H_VGA_ADDR_WIDTH = 8,
    parameter V_VGA_ADDR_WIDTH = 8,

    parameter  H_WINDOW_VISIBLE_AREA = 640,
    parameter  V_WINDOW_VISIBLE_AREA = 480,
    localparam H_WINDOW_ADDR_WIDTH   = $clog2(H_WINDOW_VISIBLE_AREA),
    localparam V_WINDOW_ADDR_WIDTH   = $clog2(V_WINDOW_VISIBLE_AREA)
    // scale positive to upscale
    // negative to downscale
    // TODO: implement scale logic
    // parameter scale = 1
) (
    input logic vga_pix_clk,
    input logic [H_VGA_ADDR_WIDTH-1:0] vga_sx,
    input logic [V_VGA_ADDR_WIDTH-1:0] vga_sy,
    output logic [H_WINDOW_ADDR_WIDTH-1:0] window_sx,
    output logic [V_WINDOW_ADDR_WIDTH-1:0] window_sy,
    output logic window_enabled,
    output logic game_pix_stb

);

  // TODO: implement game_pix_stb
  // TODO: Check overflow and whatnot
  always_ff @(posedge vga_pix_clk) begin
    // Yes, verilator is useful, but I know what  I am doing :)
    // Overflow/Underflow/WidthExpansion/Trunction doesnt matter since we check against `window_enabled`
    /* verilator lint_off WIDTHEXPAND */  /* verilator lint_off WIDTHTRUNC */
    window_sx <= vga_sx - H_WINDOW_OFFSET + 1;
    window_sy <= vga_sy - V_WINDOW_OFFSET + 1;
    window_enabled <= vga_sx - H_WINDOW_OFFSET < H_WINDOW_VISIBLE_AREA && vga_sy - V_WINDOW_OFFSET < V_WINDOW_VISIBLE_AREA - 1;
    // vga_sx > H_WINDOW_OFFSET && vga_sx + H_WINDOW_OFFSET < H_WINDOW_VISIBLE_AREA &&
    /* verilator lint_on WIDTHEXPAND */  /* verilator lint_on WIDTHTRUNC */
  end
   assign game_pix_stb = vga_pix_clk;
endmodule : display_window_mapper
