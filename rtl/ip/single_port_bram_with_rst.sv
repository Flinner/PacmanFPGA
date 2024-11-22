`timescale 1ns / 1ps

// Block RAM with Resettable Data Output
// File: rams_sp_rf_rst.v
// Source: https://docs.amd.com/r/en-US/ug901-vivado-synthesis/Single-Port-RAM-with-Asynchronous-Read-Coding-Example-VHDL
// Direct Source: https://docs.amd.com/r/en-US/ug901-vivado-synthesis/Single-Port-Block-RAM-with-Resettable-Data-Output-Verilog

// HEAVILY modified, added params, and rewrote to systemverilog

module single_port_bram_with_rst #(
    parameter DATA_WIDTH = 4,
    parameter DATA_DEPTH = 1023,
    parameter INITIAL_MEM_FILE = "NONE"
) (
    input logic clk,
    //input logic en,
    input logic we,
    input logic rst,
    input logic [$clog2(DATA_DEPTH)-1:0] addr,
    input logic [DATA_WIDTH-1:0] di,
    output logic [DATA_WIDTH-1:0] dout
);

  generate
    if (INITIAL_MEM_FILE != "NONE") begin : INITIALIZE_MEM_FROM_FILE
      initial begin
        $display("Loading MAP from init file '%s' to BRAM.", INITIAL_MEM_FILE);
        $readmemb(INITIAL_MEM_FILE, ram);
      end
    end else begin : DONT_INITIALIZE_MEM
      initial begin
        $display("BRAM not initialized!");
      end
    end
  endgenerate

  logic [DATA_WIDTH-1:0] ram[0:DATA_DEPTH-1];

  always_ff @(posedge clk) begin
    //if (en) //optional enable
    //begin
    if (we)  //write enable
      ram[addr] <= di;
    if (rst)  //optional reset
      dout <= 0;
    else dout <= ram[addr];
  end
  //end

endmodule : single_port_bram_with_rst

