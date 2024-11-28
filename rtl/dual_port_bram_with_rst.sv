`timescale 1ns / 1ps

module dual_port_bram_with_rst #(
    parameter DATA_WIDTH = 4,
    parameter DATA_DEPTH = 1023,
    parameter READ_HEX = 0,  // or HEX
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

  dual_port_bram #(  /*AUTOINSTPARAM*/
      // Parameters
      .DATA_WIDTH      (DATA_WIDTH),
      .DATA_DEPTH      (DATA_DEPTH),
      .READ_HEX        (READ_HEX),
      .INITIAL_MEM_FILE(INITIAL_MEM_FILE)
  ) dual_port_bram (  /*AUTOINST*/
      // Outputs
      .douta   (douta[DATA_WIDTH-1:0]),
      .doutb   (doutb[DATA_WIDTH-1:0]),
      // Inputs
      .clk     (clk),
      .soft_rst(soft_rst),
      .wea     (wea | wea_rst),
      .web     (web),
      .addra   (~rst_done ? addr_rst : addra[$clog2(DATA_DEPTH)-1:0]),
      .addrb   (addrb[$clog2(DATA_DEPTH)-1:0]),
      .dia     (~rst_done ? rst_source[addr_rst] : dia[DATA_WIDTH-1:0]),
      .dib     (dib[DATA_WIDTH-1:0])
  );



  generate
    if (INITIAL_MEM_FILE != "NONE" && READ_HEX == 1) begin : INITIALIZE_MEM_FROM_FILE_HEX
      initial begin
        $display("Loading MAP from init file '%s' to BRAM.", INITIAL_MEM_FILE);
        // $readmemb(INITIAL_MEM_FILE, ram);
        $readmemh(INITIAL_MEM_FILE, rst_source);
      end
    end else if (INITIAL_MEM_FILE != "NONE" && READ_HEX == 0) begin : INITIALIZE_MEM_FROM_FILE_BIN
      initial begin
        $readmemb(INITIAL_MEM_FILE, rst_source);
      end
    end else begin : DONT_INITIALIZE_MEM
      initial begin
        $display("BRAM not initialized!");
      end
    end
  endgenerate
  // Reset logic
  // chatGPTed :)

  logic [$clog2(DATA_DEPTH)-1:0] addr_rst;
  logic                          rst_done;
  logic [        DATA_WIDTH-1:0] rst_source[0:DATA_DEPTH-1];
  logic                          wea_rst;
  assign wea_rst = !rst_done;


  always @(posedge clk) begin
    if (soft_rst) begin
      addr_rst <= 0;
      rst_done <= 0;
    end else if (!rst_done) begin

      // ram[addr_rst] <= rst_source[addr_rst];  // Write zero to all BRAM locations

      /* verilator lint_off WIDTHEXPAND */
      if (addr_rst == DATA_DEPTH - 1) begin
        /* verilator lint_on WIDTHEXPAND */
        rst_done <= 1;  // Reset complete
      end else begin
        addr_rst <= addr_rst + 1;  // Increment address
      end
    end
  end

endmodule : dual_port_bram_with_rst
