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

  localparam MAX_AUDIO_SAMPLES = 40_000;
  integer AUDIO_SAMPLES;

  logic [7:0] audio_data[0:MAX_AUDIO_SAMPLES];  // 8-bit audio, 5736 samples

  localparam CHOMP_SAMPLES = 5735;
  localparam INTRO_SAMPLES = 12279;
  localparam DEATH_SAMPLES = 33735;

  logic [7:0] CHOMP_AUDIO_DATA[0:CHOMP_SAMPLES];  // 8-bit audio, 5736 samples
  logic [7:0] INTRO_AUDIO_DATA[0:INTRO_SAMPLES];  // 8-bit audio, 5736 samples
  logic [7:0] DEATH_AUDIO_DATA[0:DEATH_SAMPLES];  // 8-bit audio, 5736 samples


  initial $readmemh("mem/Chomp.mem", CHOMP_AUDIO_DATA);
  initial $readmemh("mem/Intro.mem", INTRO_AUDIO_DATA);
  initial $readmemh("mem/Death.mem", DEATH_AUDIO_DATA);

  logic [13:0] address;  // Address counter for audio samples
  logic [ 7:0] current_sample;

  always @(posedge clk_25MHZ) begin
    if (address >= AUDIO_SAMPLES) address <= 0;
    else address <= address + {12'b0, clk_8KHZ};
    current_sample <= audio_data[address];
  end

  always_comb
    case (sound_type)
      SOUND_LOADING: begin
        AUDIO_SAMPLES = INTRO_SAMPLES;
        audio_data[0:INTRO_SAMPLES] = INTRO_AUDIO_DATA;
      end
      SOUND_READY: begin
        AUDIO_SAMPLES = INTRO_SAMPLES;
        audio_data[0:INTRO_SAMPLES] = INTRO_AUDIO_DATA;
      end
      SOUND_WIN: begin
      end
      SOUND_GAME_PLAY: begin
        AUDIO_SAMPLES = CHOMP_SAMPLES;
        audio_data[0:CHOMP_SAMPLES] = CHOMP_AUDIO_DATA;
      end
      SOUND_FAIL: begin
        AUDIO_SAMPLES = DEATH_SAMPLES;
        audio_data[0:DEATH_SAMPLES] = DEATH_AUDIO_DATA;
      end
      default: ;
    endcase

  assign en = '1;

  pwm pwm_audio (
      .clk(clk_25MHZ),
      .audio_sample(current_sample),
      .pwm_out(pwm_out)
  );


endmodule : audio
