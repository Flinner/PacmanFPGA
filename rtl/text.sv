`timescale 1ns / 1ps

`ifdef VERILATOR
`include "rtl/params.sv"
`include "rtl/common_defines.svh"
`else
`include "params.sv"
`include "common_defines.svh"
`endif


module text (
    input logic clk,
    input game_mode_t MODE,
    input logic [15:0] score,
    input logic [7:0] sx,
    input logic [8:0] sy,
    output logic [3:0] R,
    output logic [3:0] G,
    output logic [3:0] B
);
  logic       pixel;
  logic [7:0] char;


  localparam WORD_LEN = 16;  // chars of a word
  localparam CHAR_HEIGHT = 8;  // chars of a word
  localparam CHAR_WIDTH = 8;  // chars of a word

  ////////////////
  // LOADING... //
  ////////////////
  localparam [7:0] TXT_LOADING[0:9] = "LOADING...";
  localparam LOADING_start_x = 8 * 13;
  localparam LOADING_start_y = 8 * 17;


  ///////////
  // READY //
  ///////////
  localparam [7:0] TXT_READY[0:5] = "READY!";
  localparam READY_start_x = 8 * 13;
  localparam READY_start_y = 8 * 17;

  localparam [7:0] TXT_PRESS[0:23] = "PRESSY ANY KEY TO START!";
  localparam PRESS_start_x = 8 * 4;
  localparam PRESS_start_y = 8 * 2;

  /////////////////
  // HIGH SCORE //
  ////////////////
  localparam [7:0] TXT_HIGHSCORE[0:9] = "HIGH SCORE";
  localparam HIGHSCORE_start_x = 8 * 11;
  localparam HIGHSCORE_start_y = 8 * 0;

  /////////////////
  // BCD SCORE //
  ////////////////
  logic [3:0] BCDSCORE[0:3];
  logic [7:0] TXT_BCDSCORE[0:3];
  localparam BCDSCORE_start_x = 8 * 5;
  localparam BCDSCORE_start_y = 8 * 1;  /* verilator lint_off WIDTHEXPAND */
  assign TXT_BCDSCORE[0] = BCDSCORE[0] + 48;  // int to ASCII
  assign TXT_BCDSCORE[1] = BCDSCORE[1] + 48;  // int to ASCII
  assign TXT_BCDSCORE[2] = BCDSCORE[2] + 48;  // int to ASCII
  assign TXT_BCDSCORE[3] = BCDSCORE[3] + 48;  // int to ASCII
  /* verilator lint_on WIDTHEXPAND */





  font font (  /**AUTOINST*/
      // Outputs
      .pixel(pixel),
      // Inputs
      .char (char),
      .sy   (sy[2:0]),
      .sx   (sx[2:0])
  );

  decimal_to_bcd #(  /**AUTOINSTPARAM*/
      // Parameters
      .BIN_WIDTH (16),
      .BCD_DIGITS(4)
  ) decimal_to_bcd_score0 (  /**AUTOINST*/
      // Outputs
      .bcd   ({BCDSCORE[0], BCDSCORE[1], BCDSCORE[2], BCDSCORE[3]}),
      // Inputs
      .binary(score)
  );



  // should return data after 1 clk :)
  // always_comb
  //   case (MODE)
  //     '0: begin
  //       // this is the center bo
  //     end
  //     '1: begin
  //     end
  //     default: begin
  //     end
  //   endcase

  always_ff @(posedge clk) begin
    char <= " ";

    // LOADING!
    /* verilator lint_off WIDTHEXPAND */
    // verilog_format: off
    if ((sy >= LOADING_start_y && sy < LOADING_start_y + CHAR_HEIGHT) && //
        (sx >= LOADING_start_x && sx < LOADING_start_x + ($size(TXT_LOADING) * CHAR_WIDTH)) && //
        (MODE == GAME_MODE_LOADING)) begin
    // verilog_format: on
      char <= TXT_LOADING[(sx-LOADING_start_x)/8];
      /* verilator lint_on WIDTHEXPAND */
    end

    // READY!
    /* verilator lint_off WIDTHEXPAND */
    // verilog_format: off
    if ((sy >= READY_start_y && sy < READY_start_y + CHAR_HEIGHT) && //
        (sx >= READY_start_x && sx < READY_start_x + ($size(TXT_READY) * CHAR_WIDTH)) && //
        (MODE == GAME_MODE_READY)) begin
    // verilog_format: on
      char <= TXT_READY[(sx-READY_start_x)/8];
      /* verilator lint_on WIDTHEXPAND */
    end
    /* verilator lint_off WIDTHEXPAND */
    // verilog_format: off
    if ((sy >= PRESS_start_y && sy < PRESS_start_y + CHAR_HEIGHT) && //
        (sx >= PRESS_start_x && sx < PRESS_start_x + ($size(TXT_PRESS) * CHAR_WIDTH)) && //
        (MODE == GAME_MODE_READY)) begin
    // verilog_format: on
      char <= TXT_PRESS[(sx-PRESS_start_x)/8];
      /* verilator lint_on WIDTHEXPAND */
    end

    /* verilator lint_off WIDTHEXPAND */
    // verilog_format: off
    if ((  /* sy >= HIGHSCORE_start_y && */ sy < HIGHSCORE_start_y + CHAR_HEIGHT) &&  //
        (sx >= HIGHSCORE_start_x && sx < HIGHSCORE_start_x + ($size(TXT_HIGHSCORE) * CHAR_WIDTH)) &&
        (MODE != GAME_MODE_LOADING)) begin
      // verilog_format: on
      char <= TXT_HIGHSCORE[(sx-HIGHSCORE_start_x)/8];
      /* verilator lint_on WIDTHEXPAND */
    end

    // verilog_format: off
    /* verilator lint_off WIDTHEXPAND */
    if ((sy >= BCDSCORE_start_y && sy < BCDSCORE_start_y + CHAR_HEIGHT) &&  //
        (sx >= BCDSCORE_start_x && sx < BCDSCORE_start_x + ($size(TXT_BCDSCORE) * CHAR_WIDTH)) &&
        (MODE != GAME_MODE_LOADING)) begin
      // verilog_format: on
      char <= TXT_BCDSCORE[(sx-BCDSCORE_start_x)/8];
      /* verilator lint_on WIDTHEXPAND */
    end

  end

  always_comb begin
    R = {4{pixel}};
    G = {4{pixel}};
    B = {4{pixel}};
  end


endmodule : text
