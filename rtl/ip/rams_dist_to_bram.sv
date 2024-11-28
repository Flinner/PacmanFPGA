`timescale 1ns / 1ps


module rams_dist_to_bram #(
    parameter DATA_WIDTH = 4,
    parameter DATA_DEPTH = 1023,
    parameter INITIAL_MEM_FILE = "NONE"
) (
    input  logic                          clk,
    input  logic [$clog2(DATA_DEPTH)-1:0] a,
    output logic [        DATA_WIDTH-1:0] spo
);


  dual_port_bram_with_rst #(  /*AUTOINSTPARAM*/
      // Parameters
      .DATA_WIDTH      (DATA_WIDTH),
      .READ_HEX        (1),                // monsters  use BIN, map uses HEX lol
      .DATA_DEPTH      (DATA_DEPTH),
      .INITIAL_MEM_FILE(INITIAL_MEM_FILE)
  ) rams_dist_to_bram (  /*AUTOINST*/
      // Outputs
      .douta   (spo),
      .doutb   (),
      // Inputs
      .clk     (clk),
      .soft_rst('0),
      .wea     ('0),
      .web     ('0),
      .addra   (a + 1),
      .addrb   ('0),
      .dia     ('0),
      .dib     ('0)
  );



endmodule
