`timescale 1ns / 1ps

// File: rams_sp_rf_rst.v
// Source: https://docs.amd.com/r/en-US/ug901-vivado-synthesis/Single-Port-RAM-with-Asynchronous-Read-Coding-Example-VHDL
// Direct Source: https://docs.amd.com/r/en-US/ug901-vivado-synthesis/Single-Port-Block-RAM-with-Resettable-Data-Output-Verilog

// HEAVILY modified, added params, and rewrote to systemverilog, and made it dual port lol

module dual_port_bram #(
    parameter DATA_WIDTH = 4,
    parameter DATA_DEPTH = 1023,
    parameter INITIAL_MEM_FILE = "NONE"
) (
    input logic clk,
    //input logic en,
    input logic wea,
    input logic web,
    input logic [$clog2(DATA_DEPTH)-1:0] addra,
    input logic [$clog2(DATA_DEPTH)-1:0] addrb,
    input logic [DATA_WIDTH-1:0] dia,
    input logic [DATA_WIDTH-1:0] dib,
    output logic [DATA_WIDTH-1:0] douta,
    output logic [DATA_WIDTH-1:0] doutb
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

  // A
  always_ff @(posedge clk) begin
    if (wea)  //write enable
      ram[addra] <= dia;
    douta <= ram[addra];
  end

  // B
  always_ff @(posedge clk) begin
    if (web)  //write enable
      ram[addrb] <= dib;
    doutb <= ram[addrb];
  end

endmodule : dual_port_bram

