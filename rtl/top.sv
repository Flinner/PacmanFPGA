`timescale 1ns / 1ps

`ifdef VERILATOR
// this removes many bugs!
// vivado is shit, I hate it 
// I hate it I hate it I hate it I hate it
// I hate it I hate it I hate it I hate it
// I hate it I hate it I hate it I hate it
// I hate it I hate it I hate it I hate it
// I hate it I hate it I hate it I hate it
`default_nettype none
`include "rtl/params.sv"
`include "rtl/common_defines.svh"
`else
`include "common_defines.svh"
`endif

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
    output logic vga_pix_clk,
`endif
    input logic CLK100MHZ,
    input logic CPU_RESETN,
    input logic BTNU,
    input logic BTND,
    input logic BTNR,
    input logic BTNL,
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

  // we give sx and sy ahead of time to pipeline!
  localparam PIPELINE_STAGES = params::vga::PIPELINE_STAGES;
  logic [H_ADDR_WIDTH-1:0] sx_aot;  // aot=Ahead Of Time!
  logic [V_ADDR_WIDTH-1:0] sy_aot;
  logic display_enabled_aot;

  logic CLK25MHZ;
  // logic frame_stb;  // strobe each new frame
  logic frame_stb_aot;  // strobe each new frame

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
  // FIXME: Assert rst for a few cycles at start

  // assign frame_stb = sy == sx && sx == 0;
  assign frame_stb_aot = sy_aot == sx_aot && sx_aot == 0;

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
      .clk(CLK100MHZ),  // unused for now
      .vga_pix_clk(CLK25MHZ),
      .rst(soft_rst | ~CPU_RESETN),
      .frame_stb(frame_stb_aot),
      .sx(sx_aot),
      .sy(sy_aot),
      .BTNU(BTNU),
      .BTNL(BTNL),
      .BTNR(BTNR),
      .BTND(BTND),
      .R(VGA_R),
      .G(VGA_G),
      .B(VGA_B),
      .sound_type(sound_type),
      .display_enabled(display_enabled_aot)
  );

  always_comb begin
    if (sx + PIPELINE_STAGES > H_WHOLE_LINE - 1) begin
      // sx-PIPELINE_STAGE<0, but with overflow...
      // this path means we should increase sy
      sx_aot = PIPELINE_STAGES - (H_WHOLE_LINE - sx);
      if (sy + 1 > V_WHOLE_LINE - 1) sy_aot = 0;
      else sy_aot = sy + 1;
    end else begin
      sx_aot = sx + PIPELINE_STAGES;
      sy_aot = sy;
    end
    // $display("x_a,x: %d, %d, y_: %d, %d", sx_aot, sx, sy_aot, sy);
    // $display("x_a: %d, y_: %d", sx_aot, sy_aot);
  end
  always_comb display_enabled_aot = (sx_aot < H_VISIBLE_AREA && sy_aot < V_VISIBLE_AREA);


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
      .vga_pix_clk(CLK25MHZ),
      .rst('0),  // never reset vga
      .display_enabled(display_enabled),
      .H_SYNC(VGA_HS),
      .V_SYNC(VGA_VS),
      .sx(sx),
      .sy(sy)
  );

  /////////////////
  // RESET LOGIC //
  /////////////////
  // Explicit rst signal needs to be asserted at the beginning, to set pacman/enemies at correct position

  logic soft_rst;
  reset_generator #(  /*AUTOINSTPARAM*/
      // Parameters
      .RESET_CYCLES(32 * 36 + 10)  // should probably move this to a variable :smile: (+10 just in case)
  ) reset_generator (
      /**AUTOINST*/
      // Outputs
      .reset(soft_rst),
      // Inputs
      .trigger_reset(~CPU_RESETN),
      .clk(CLK25MHZ)
  );


  ///////////
  // SOUND //
  ///////////
  sound_t sound_type;
`ifndef VERILATOR  // NO AUDIO IN VERILATOR SIMULATION :(
  audio audio (  /**AUTOINST*/
      // Interfaces
      .sound_type(sound_type),
      // Outputs
      .clk_8KHZ(STROBE_8KHZ),
      .clk_25MHZ(CLK25MHZ),
      .pwm_out(AUD_PWM),
      .en(AUD_SD)
  );
`endif
`ifndef VERILATOR
  logic STROBE_8KHZ;
  precise_div #(
      .CLKS_PER_STB(25_000_000 / 8_000)
  ) clk_8khz (  /**AUTOINST*/
      // Outputs
      .o_stb  (STROBE_8KHZ),
      // Inputs
      .i_clk  (CLK25MHZ),
      .i_reset(~CPU_RESETN)
  );
`endif

endmodule
