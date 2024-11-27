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

`ifndef PARAMS_SV
`define PARAMS_SV
package params;
  class pacman;
    // The pacman game is 224x288 pixels.
    // which is divided into 256x36 blocks on a map.
    // NOTE: THIS IS DOUBLE DIFNED
    parameter H_VISIBLE_AREA = 256;
    parameter V_VISIBLE_AREA = 288;
  endclass : pacman
  class vga;
    parameter PIPELINE_STAGES = 2;  // 7 choosen based on my hunch
  endclass : vga
  class map;
    parameter empty_tile = 'b1000;
    parameter cookie_tile = 'b1010;
    parameter candy_tile = 'b1001;
    parameter candy_count = 'd231;
  endclass : map
endpackage : params
`endif
