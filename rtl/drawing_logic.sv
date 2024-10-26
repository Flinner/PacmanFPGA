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
    rst,
    frame_stb,
    input logic [H_ADDR_WIDTH-1:0] sx,
    input logic [V_ADDR_WIDTH-1:0] sy,
    input logic display_enabled
);


  localparam SQ_SIDE = 50;

  logic [H_ADDR_WIDTH-1:0] SQ_x;
  logic [V_ADDR_WIDTH-1:0] SQ_y;
  logic square;

  assign square = (sx > SQ_x && sx < SQ_x + SQ_SIDE) && (sy > SQ_y && sy < SQ_y + SQ_SIDE);

  logic x_direction;
  logic y_direction;
  localparam x_sp = 3;
  localparam y_sp = 5;

  always_ff @(posedge clk)
    if (rst) begin
      SQ_x <= H_VISIBLE_AREA / 2;  // 320
      SQ_y <= V_VISIBLE_AREA / 2;
    end else if (frame_stb) begin

      if (x_direction)  // moving left
        if (SQ_x + SQ_SIDE + x_sp >= H_VISIBLE_AREA - 1) begin
          SQ_x <= H_VISIBLE_AREA - SQ_SIDE;
          x_direction <= 0;
        end else begin
          SQ_x <= SQ_x + x_sp;
        end
      else if (SQ_x < x_sp) begin  // moving right
        SQ_x <= 0;
        x_direction <= 1;
      end else SQ_x <= SQ_x - x_sp;

      if (y_direction)  // moving left
        if (SQ_y + SQ_SIDE + y_sp >= V_VISIBLE_AREA - 1) begin
          SQ_y <= V_VISIBLE_AREA - SQ_SIDE;
          y_direction <= 0;
        end else begin
          SQ_y <= SQ_y + y_sp;
        end
      else if (SQ_y < y_sp) begin  // moving right
        SQ_y <= 0;
        y_direction <= 1;
      end else SQ_y <= SQ_y - y_sp;

      // if (y_direction)  //
      //   SQ_y <= SQ_y + 10;
      // else  //
      //   SQ_y <= SQ_y - 10;


    end



  always_comb begin
    R = square ? 'hF : '0;
    G = R;
    B = R;
    if (!display_enabled) begin
      R = '0;
      G = '0;
      B = '0;
    end
  end
endmodule
