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

module sprite_map (
    input  logic [2:0] sx,
    input  logic [2:0] sy,
    input  logic [3:0] sprite_code,
    output logic [3:0] R,
    output logic [3:0] G,
    output logic [3:0] B
);

  always_comb begin
    G = '0;
    B = '0;
    case (sprite_code)
      'b0000: R = 'b1111;
      'b0001: R = 'b1111;
      'b0010: R = 'b1111;
      'b0011: R = 'b1111;
      'b0100: R = 'b1111;
      'b0101: R = 'b1111;
      'b0110: R = 'b1111;
      'b0111: R = 'b1111;
      'b1001: begin
        R = 'b0000;
        if ((sy == 4 || sy == 3) && (sx == 4 || sx == 3)) G = 'b1111;
        else G = '0;
      end
      'b1010: begin
        R = 'b0000;
        if ((sy < 6 && sy > 2) && (sx < 6 && sx > 2)) B = 'b1111;
        else B = '0;
      end
      default: begin
        R = '0;
      end
    endcase
  end

endmodule : sprite_map
