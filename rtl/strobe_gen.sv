`timescale 1ns / 1ps

module strobe_gen #(
    parameter CLOCK_FREQ_HZ = 25_000_000,  // Clock frequency in Hz (e.g., 100 MHz)
    parameter STROBE_TIME_S = 1            // Duration of the strobe in seconds
) (
    input  logic clk,    // Clock input
    input  logic start,  // Reset input
    output logic strobe  // Strobe signal output
);

  localparam integer MAX_COUNT = CLOCK_FREQ_HZ * STROBE_TIME_S;  // Total clock cycles for strobe time

  logic [$clog2(MAX_COUNT)-1:0] counter;  // Counter to count clock cycles
  logic                         start_old;


  always_ff @(posedge clk) begin
    start_old <= start;

    if (start_old != start) begin
      counter <= 0;
      strobe  <= 1;
      /* verilator lint_off WIDTHEXPAND*/
    end else if (counter < MAX_COUNT) begin
      /* verilator lint_on WIDTHEXPAND*/
      counter <= counter + 1;
      strobe  <= 1;  // Strobe remains high during the duration
    end else begin
      strobe <= 0;  // Deactivate strobe after the duration
    end
  end

endmodule
