`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:  
// 
// Create Date: 10/18/2024 03:01:12 PM
// Design Name: 
// Module Name: top
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


module top (
`ifdef VERILATOR
    output logic [H_ADDR_WIDTH-1:0] sx,
    output logic [V_ADDR_WIDTH-1:0] sy,
    output logic display_enabled,
    output logic pix_clk,
`endif
    input logic CLK100MHZ,
    input logic CPU_RESETN,
    output logic [3:0] VGA_R,
    VGA_G,
    VGA_B,
    output logic VGA_HS,
    VGA_VS

);


  localparam H_VISIBLE_AREA = 640;
  localparam H_FRONT_PORCH = 16;
  localparam H_SYNC_PULSE = 96;
  localparam H_BACK_PORCH = 48;
  localparam V_VISIBLE_AREA = 480;
  localparam V_FRONT_PORCH = 10;
  localparam V_SYNC_PULSE = 2;
  localparam V_BACK_PORCH = 33;
  localparam H_WHOLE_LINE = H_VISIBLE_AREA + H_FRONT_PORCH + H_SYNC_PULSE + H_BACK_PORCH;
  localparam V_WHOLE_LINE = V_VISIBLE_AREA + V_FRONT_PORCH + V_SYNC_PULSE + V_BACK_PORCH;
  localparam H_ADDR_WIDTH = $clog2(H_WHOLE_LINE);
  localparam V_ADDR_WIDTH = $clog2(V_WHOLE_LINE);


  logic CLK25MHZ;
  logic frame_stb;  // strobe each new frame

  // avoid double declartion
`ifndef VERILATOR
  logic [H_ADDR_WIDTH-1:0] sx;
  logic [V_ADDR_WIDTH-1:0] sy;
  logic display_enabled;
`endif

`ifdef VERILATOR
  assign CLK25MHZ = CLK100MHZ;
`else
  clk_wiz_0 clk25 (
      .clk_out1(CLK25MHZ),
      .clk_in1 (CLK100MHZ)
  );
`endif

  assign frame_stb = sy == sx && sx == 0;

  drawing_logic #(
      .H_VISIBLE_AREA(H_VISIBLE_AREA),
      .H_FRONT_PORCH (H_FRONT_PORCH),
      .H_SYNC_PULSE  (H_SYNC_PULSE),
      .H_BACK_PORCH  (H_BACK_PORCH),
      .V_VISIBLE_AREA(V_VISIBLE_AREA),
      .V_FRONT_PORCH (V_FRONT_PORCH),
      .V_SYNC_PULSE  (V_SYNC_PULSE),
      .V_BACK_PORCH  (V_BACK_PORCH)
  ) drawing_logic (
      .clk(CLK25MHZ),
      .pix_clk(),
      .rst(~CPU_RESETN),
      .frame_stb(frame_stb),
      .sx(sx),
      .sy(sy),
      .R(VGA_R),
      .G(VGA_G),
      .B(VGA_B),
      .display_enabled(display_enabled)
  );


  vga_signal_gen #(
      .H_VISIBLE_AREA(H_VISIBLE_AREA),
      .H_FRONT_PORCH (H_FRONT_PORCH),
      .H_SYNC_PULSE  (H_SYNC_PULSE),
      .H_BACK_PORCH  (H_BACK_PORCH),
      .V_VISIBLE_AREA(V_VISIBLE_AREA),
      .V_FRONT_PORCH (V_FRONT_PORCH),
      .V_SYNC_PULSE  (V_SYNC_PULSE),
      .V_BACK_PORCH  (V_BACK_PORCH)
  ) vga1 (
      .pix_clk(CLK25MHZ),
      .rst(~CPU_RESETN),
      .display_enabled(display_enabled),
      .H_SYNC(VGA_HS),
      .V_SYNC(VGA_VS),
      .sx(sx),
      .sy(sy)
  );

endmodule
