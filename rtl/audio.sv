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

  logic [7:0] chomp_byte;
  logic [7:0] intro_byte;
  logic [7:0] death_byte;



  initial $readmemh("mem/Chomp.mem", CHOMP_AUDIO_DATA);
  initial $readmemh("mem/Intro.mem", INTRO_AUDIO_DATA);
  initial $readmemh("mem/Death.mem", DEATH_AUDIO_DATA);

  single_port_bram_with_rst #(  /*AUTOINSTPARAM*/
      // Parameters
      .DATA_WIDTH      (8),
      .DATA_DEPTH      (CHOMP_SAMPLES),
      .INITIAL_MEM_FILE("mem/Chomp.mem")
  ) bram_chomp (  /*AUTOINST*/
      // Outputs
      .dout(chomp_byte),
      // Inputs
      .clk (clk_25MHZ),
      .we  ('0),
      .rst ('0),
      .addr(address),
      .di  ('0)
  );

  single_port_bram_with_rst #(  /*AUTOINSTPARAM*/
      // Parameters
      .DATA_WIDTH      (8),
      .DATA_DEPTH      (INTRO_SAMPLES),
      .INITIAL_MEM_FILE("mem/Intro.mem")
  ) bram_intro (  /*AUTOINST*/
      // Outputs
      .dout(intro_byte),
      // Inputs
      .clk (clk_25MHZ),
      .we  ('0),
      .rst ('0),
      .addr(address),
      .di  ('0)
  );

  single_port_bram_with_rst #(  /*AUTOINSTPARAM*/
      // Parameters
      .DATA_WIDTH      (8),
      .DATA_DEPTH      (DEATH_SAMPLES),
      .INITIAL_MEM_FILE("mem/Death.mem")
  ) brm_death (  /*AUTOINST*/
      // Outputs
      .dout(death_byte),
      // Inputs
      .clk (clk_25MHZ),
      .we  ('0),
      .rst ('0),
      .addr(address),
      .di  ('0)
  );


  logic [13:0] address;  // Address counter for audio samples
  logic [ 7:0] current_sample;

  always @(posedge clk_25MHZ) begin
    if (address >= AUDIO_SAMPLES) address <= 0;
    else address <= address + {12'b0, clk_8KHZ};
    // current_sample <= audio_data[address];
  end

  always_comb
    case (sound_type)
      SOUND_LOADING: begin
        current_sample = intro_byte;
      end
      SOUND_READY: begin
        current_sample = intro_byte;
      end
      SOUND_WIN: begin
      end
      SOUND_GAME_PLAY: begin
        current_sample = chomp_byte;
      end
      SOUND_FAIL: begin
        current_sample = death_byte;
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
