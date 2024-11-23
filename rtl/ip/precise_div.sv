`timescale 1ns / 1ps
// Written by Flinner (ME!)
// Source: https://github.com/Flinner/FFFSys/blob/main/rtl/precise_div.v
// I am reusing what I wrote in the past B)
module precise_div #(
    parameter CLKS_PER_STB = 2
) (
    input  wire i_clk,    /* verilator lint_off UNUSEDSIGNAL */
    input  wire i_reset,  /* verilator lint_on UNUSEDSIGNAL */
    output wire o_stb
);
  localparam WIDTH = $clog2(CLKS_PER_STB);


  // before overflowing
  generate
    if (CLKS_PER_STB == 1) begin : gen_nodiv
      assign o_stb = i_clk;
    end else begin : gen_div
      reg [WIDTH-1:0] count;
      always @(posedge i_clk)
        if (i_reset) count <= 0;
        else count <= count + 1;
      assign o_stb = (count == CLKS_PER_STB[WIDTH-1:0]);
    end
  endgenerate

endmodule : precise_div
