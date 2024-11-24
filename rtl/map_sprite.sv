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

module map_sprite (
    input  logic [2:0] sx,
    input  logic [2:0] sy,
    input  logic [3:0] sprite_code,
    output logic [3:0] R,
    output logic [3:0] G,
    output logic [3:0] B
);

  always_comb begin
    // Default output values


    case (sprite_code)
      // Upper wall
      4'b0001:
      if (sy == 3'd4) B = 4'b1111;  // sy = 5 in binary
      else B = 4'b0000;
      // Right wall
      4'b0010:
      if (sx == 3'd4) B = 4'b1111;  // sx = 3 in binary
      else B = 4'b0000;
      // Lower wall
      4'b0011:
      if (sy == 3'd4) B = 4'b1111;  // sy = 3 in binary
      else B = 4'b0000;
      // Left wall
      4'b0100:
      if (sx == 3'd4) B = 4'b1111;  // sx = 5 in binary
      else B = 4'b0000;
      // Upper left corner 
      4'b0101:
      if ((sy == 3'd4 && sx >= 3'd4) || (sy >= 3'd4 && sx == 3'd4)) B = 4'b1111;
      else B = 4'b0000;
      // Upper right corner
      4'b0110:
      if ((sy == 3'd4 && sx <= 3'd4) || (sy >= 3'd4 && sx == 3'd4)) B = 4'b1111;
      else B = 4'b0000;
      // Lower right corner
      4'b0111:
      if ((sy == 3'd4 && sx <= 3'd4) || (sy <= 3'd4 && sx == 3'd4)) B = 4'b1111;
      else B = 4'b0000;
      // Lower left corner  
      4'b0000:
      if ((sy == 3'd4 && sx >= 3'd4) || (sy <= 3'd4 && sx == 3'd4)) B = 4'b1111;
      else B = 4'b0000;
      // candy
      'b1001: begin
        R = 'b0000;
        if ((sy == 4 || sy == 3) && (sx == 4 || sx == 3)) G = 'b1111;
        else G = '0;
      end
      // power cookie
      'b1010: begin
        R = 'b0000;
        if ((sy < 6 && sy > 2) && (sx < 6 && sx > 2)) B = 'b1111;
        else B = '0;
      end
      default: begin
        B = 4'b0000;
        R = '0;
      end
    endcase
  end

endmodule
