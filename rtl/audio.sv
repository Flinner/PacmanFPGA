`timescale 1ns / 1ps
`ifdef VERILATOR
`include "rtl/common_defines.svh"
`else
`include "common_defines.svh"
`endif

module audio (
    input  sound_t sound_type,
    input  logic   clk_8KHZ,
    input  logic   clk_25MHZ,
    output logic   pwm_out,
    output logic   en
);

  reg [7:0] chomp_audio_data[0:5735];  // 8-bit audio, 5736 samples
  initial $readmemh("mem/Chomp.mem", chomp_audio_data);

  reg [12:0] address;  // Address counter for audio samples
  reg [ 7:0] current_sample;

  always @(posedge clk_8KHZ) begin
    address <= address + 1;
    current_sample <= chomp_audio_data[address];
  end

  assign en = '1;

  pwm pwm_audio (
      .clk(clk_8KHZ),
      .audio_sample(current_sample),
      .pwm_out(pwm_out)
  );

endmodule : audio
