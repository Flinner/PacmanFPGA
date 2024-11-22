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

`ifdef VERILATOR
`include "rtl/params.sv"
`endif

module cookie_candy (
    // this is pacman's map tile
    input logic [3:0] map_pacman_tile,
    input logic       vga_pix_clk,
    input logic       rst,

    output logic ate_candy_stb,
    output logic ate_power_cookie_stb
);

  // this is to fix timing shit caused by reading memory, give it no mind
  logic ate_candy1;
  logic ate_power_cookie1;
  // I convert 3 strobes to 1.



  always_ff @(posedge vga_pix_clk) begin
    if (rst) begin
      ate_candy_stb <= 0;
      ate_power_cookie_stb <= 0;
      ate_candy1 <= 0;
      ate_power_cookie1 <= 0;
    end
    ate_candy1 <= ate_candy_stb;
    ate_power_cookie1 <= ate_power_cookie_stb;

    ate_candy_stb <= (map_pacman_tile == params::map::candy_tile) & ~ate_candy_stb & ~ate_candy1;
    ate_power_cookie_stb <= (map_pacman_tile == params::map::cookie_tile) & ~ate_power_cookie_stb & ~ate_power_cookie1;
    if (ate_candy_stb | ate_power_cookie_stb) begin
      $display("map_pacman_tile: %b", map_pacman_tile);
      $display("CANDY: %b, POWER: %b", ate_candy_stb, ate_power_cookie_stb);
    end
  end

endmodule : cookie_candy
