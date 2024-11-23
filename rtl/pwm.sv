`timescale 1ns / 1ps
// heavily from chatGPT :)

module pwm (
    input  logic       clk,           // System clock
    input  logic [7:0] audio_sample,  // 8-bit audio sample
    output logic       pwm_out        // PWM output
);
  logic [7:0] counter;  // Counter for PWM

  always @(posedge clk) counter <= counter + 1;

  assign pwm_out = (counter < audio_sample) ? 1'b1 : 1'b0;
endmodule
