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
    // which is divided into 28x36 blocks on a map.
    // NOTE: THIS IS DOUBLE DIFNED
    parameter H_VISIBLE_AREA = 224;
    parameter V_VISIBLE_AREA = 288;
  endclass : pacman


endpackage : params

`endif
