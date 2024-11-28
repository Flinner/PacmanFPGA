`timescale 1ns / 1ps

// File: rams_sp_rf_rst.v
// Source: https://docs.amd.com/r/en-US/ug901-vivado-synthesis/Single-Port-RAM-with-Asynchronous-Read-Coding-Example-VHDL
// Direct Source: https://docs.amd.com/r/en-US/ug901-vivado-synthesis/Single-Port-Block-RAM-with-Resettable-Data-Output-Verilog

// HEAVILY modified, added params, and rewrote to systemverilog, and made it dual port lol

module dual_port_bram #(
    parameter DATA_WIDTH = 4,
    parameter DATA_DEPTH = 1023,
    parameter READ_HEX = 0,
    parameter INITIAL_MEM_FILE = "NONE"
) (
    input logic clk,
    //input logic en,
    input logic soft_rst,
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
    if (INITIAL_MEM_FILE != "NONE" && READ_HEX == 1) begin : INITIALIZE_MEM_FROM_FILE_HEX
      initial begin
        $display("Loading MAP from init file '%s' to BRAM.", INITIAL_MEM_FILE);
        // $readmemb(INITIAL_MEM_FILE, ram);
        $readmemh(INITIAL_MEM_FILE, ram);
      end
    end else if (INITIAL_MEM_FILE != "NONE" && READ_HEX == 0) begin : INITIALIZE_MEM_FROM_FILE_BIN
      initial begin
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


  // Reset logic
  // chatGPTed :)

  //  logic [$clog2(DATA_DEPTH)-1:0] addr_rst;
  //  logic                          rst_done;
  //  logic [        DATA_WIDTH-1:0] rst_source[0:DATA_DEPTH-1];

  //  always @(posedge clk) begin
  //    if (soft_rst) begin
  //      addr_rst <= 0;
  //      rst_done <= 0;
  //    end else if (!rst_done) begin
  //      ram[addr_rst] <= rst_source[addr_rst];  // Write zero to all BRAM locations
  //      /* verilator lint_off WIDTHEXPAND */
  //      if (addr_rst == DATA_DEPTH - 1) begin
  //        /* verilator lint_on WIDTHEXPAND */
  //        rst_done <= 1;  // Reset complete
  //      end else begin
  //        addr_rst <= addr_rst + 1;  // Increment address
  //      end
  //    end
  //  end

endmodule : dual_port_bram

