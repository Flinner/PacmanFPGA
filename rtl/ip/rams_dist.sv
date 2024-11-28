`timescale 1ns / 1ps

// Dual-Port RAM with Asynchronous Read (Distributed RAM)
// File: rams_dist.v
// Direct Source: https://docs.amd.com/r/en-US/ug901-vivado-synthesis/Dual-Port-RAM-with-Asynchronous-Read-Coding-Verilog-Example

module rams_dist #(
    parameter DATA_WIDTH = 4,
    parameter DATA_DEPTH = 1023,
    parameter INITIAL_MEM_FILE = "NONE"
) (
    input logic [$clog2(DATA_DEPTH)-1:0] a,
    output logic [DATA_WIDTH-1:0] spo
);

  generate
    if (INITIAL_MEM_FILE != "NONE") begin : INITIALIZE_MEM_FROM_FILE
      initial begin
        $display("Loading MAP from init file '%s' to Distributed RAM.", INITIAL_MEM_FILE);
        $readmemh(INITIAL_MEM_FILE, ram);
      end
    end else begin : DONT_INITIALIZE_MEM
      initial begin
        $display("Distributed RAM not initialized!");
      end
    end
  endgenerate


  logic [DATA_WIDTH-1:0] ram[0:DATA_DEPTH-1];

  assign spo = ram[a];

endmodule
