`timescale 1ns / 1ps
// chatGPTed :)
module reset_generator (
    input wire clk,  // Clock signal
    input trigger_reset,
    //input  wire power_on,  // Power-on signal (can be tied to 1)
    output reg reset  // Reset signal
);
  parameter RESET_CYCLES = 16;  // Number of clock cycles to assert reset

  reg [$clog2(RESET_CYCLES):0] counter;  // Counter to track clock cycles

  // Initialize counter and reset signal
  initial begin
    counter = 0;
    reset   = 1'b1;
  end

  // Reset generation logic
  always @(posedge clk) begin
    if (trigger_reset) reset <= 1;

    if (reset) begin
      /* verilator lint_off WIDTHEXPAND */
      if (counter < RESET_CYCLES) begin
        /* verilator lint_on WIDTHEXPAND */
        counter <= counter + 1;
      end else begin
        counter <= 0;
        reset   <= 1'b0;  // De-assert reset after RESET_CYCLES
      end
    end
  end
endmodule
