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


module drawing_logic #(
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
    output logic [3:0] R,
    G,
    B,
    input logic pix_clk,
    clk,
    input logic [H_ADDR_WIDTH-1:0] sx,
    input logic [V_ADDR_WIDTH-1:0] sy,
    input logic display_enabled
);


  // localparam SQ_SIDE = 50;

  // logic [H_ADDR_WIDTH-1:0] SQ_x;
  // logic [V_ADDR_WIDTH-1:0] SQ_y;
  // logic square;

  // always_comb begin
  //   SQ_x = H_VISIBLE_AREA / 2;  // 320
  //   SQ_y = V_VISIBLE_AREA / 2;
  // end
  // //340-320 < 25? yes.
  // assign square = (SQ_x - sx < SQ_SIDE/2 || sx - SQ_x < SQ_SIDE/2 ) &&
  //       (SQ_y - sy < SQ_SIDE/2 || sy - SQ_y < SQ_SIDE/2 );



  always_comb begin
    R = (sx[6] ? 'hF : '0) ^ (sy[6] ? 'hF : 'h0);
    G = R;
    B = R;
    if (!display_enabled) begin
      R = '0;
      G = '0;
      B = '0;
    end
  end
endmodule
