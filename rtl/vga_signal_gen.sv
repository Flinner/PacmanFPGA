`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/18/2024 03:00:38 PM
// Design Name: 
// Module Name: vga_signal_gen
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

// http://www.tinyvga.com/vga-timing/640x480@60Hz

module vga_signal_gen #(
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
    input logic vga_pix_clk,
    rst,
    output logic H_SYNC,
    V_SYNC,
    // output logic [3:0] R, G, B,
    output logic [H_ADDR_WIDTH-1:0] sx,
    output logic [V_ADDR_WIDTH-1:0] sy,
    output logic display_enabled
);



  always_ff @(posedge vga_pix_clk) begin

    if (sx == H_WHOLE_LINE - 1) begin
      sx <= 0;
      sy <= (sy == V_WHOLE_LINE - 1) ? 0 : sy + 1;
    end else begin
      sx <= sx + 1;
    end
    if (rst) begin
      sx <= 0;
      sy <= 0;
    end
  end


  always_comb begin
    H_SYNC = ~(sx >= H_VISIBLE_AREA + H_FRONT_PORCH && sx <  H_VISIBLE_AREA + H_FRONT_PORCH + H_SYNC_PULSE);
    V_SYNC = ~(sy >= V_VISIBLE_AREA + V_FRONT_PORCH && sy <  V_VISIBLE_AREA + V_FRONT_PORCH + V_SYNC_PULSE);
  end

  always_comb display_enabled = (sx < H_VISIBLE_AREA && sy < V_VISIBLE_AREA);
endmodule
