
`timescale 1ns / 1ps
`ifdef VERILATOR
`include "rtl/common_defines.svh"
`else
`include "common_defines.svh"
`endif

module audio (
    input  sound_t sound_type,
    input  logic   clk_8KHZ,    // this is actually strobe, not clock
    input  logic   clk_25MHZ,
    output logic   pwm_out,
    output logic   en
);

  localparam AUDIO_SAMPLES = 5735;
  logic [7:0] chomp_audio_data[0:AUDIO_SAMPLES];  // 8-bit audio, 5736 samples
  initial $readmemh("mem/Chomp.mem", chomp_audio_data);

  logic [12:0] address;  // Address counter for audio samples
  logic [ 7:0] current_sample;

  always @(posedge clk_25MHZ) begin
    if (address >= AUDIO_SAMPLES) address <= 0;
    else address <= address + {12'b0, clk_8KHZ};
    current_sample <= chomp_audio_data[address];
  end

  assign en = '1;

  pwm pwm_audio (
      .clk(clk_25MHZ),
      .audio_sample(current_sample),
      .pwm_out(pwm_out)
  );


endmodule : audio
