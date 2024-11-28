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
  logic [7:0] ascii_char;


  localparam WORD_LEN = 16;  // chars of a word
  localparam CHAR_HEIGHT = 8;  // chars of a word
  localparam CHAR_WIDTH = 8;  // chars of a word

  //////////////
  // FLASHING //
  //////////////
  /* verilator lint_off WIDTHEXPAND */
  logic flash;


  strobe_gen #(  /**AUTOINSTPARAM*/
      // Parameters
`ifdef VERILATOR
      .CLOCK_FREQ_HZ(2_000_000),
`endif
      .STROBE_TIME_S(1)
  ) flashing_timer (  /**AUTOINST*/
      // Outputs
      .strobe(flash),
      // Inputs
      .clk   (clk),
      .start ('0)
  );



  ////////////////
  // LOADING... //
  ////////////////
  localparam [7:0] TXT_LOADING[0:9] = {"L", "O", "A", "D", "I", "N", "G", ".", ".", "."};
  localparam LOADING_start_x = 8 * 13;
  localparam LOADING_start_y = 8 * 17;


  ////////////////
  // LOST... //
  ////////////////
  localparam [7:0] TXT_LOST[0:10] = {"Y", "O", "U", " ", "L", "O", "S", "T", " ", ":", "("};
  localparam LOST_start_x = 8 * 13;
  localparam LOST_start_y = 8 * 17;

  // verilog_format: off
  localparam [7:0] TXT_RESET[0:24] = {
        "P","R","E","S","S"," ",
        "R","E","S","E","T"," ",
        "T","O"," ",
        "P","L","A","Y"," ",
        "A","G","A","I","N"
  };
    // verilog_format: on
  localparam RESET_start_x = 8 * 4;
  localparam RESET_start_y = 8 * 2;


  ///////////
  // READY //
  ///////////
  localparam [7:0] TXT_READY[0:5] = {"R", "E", "A", "D", "Y", "!"};
  localparam READY_start_x = 8 * 13;
  localparam READY_start_y = 8 * 17;

  // verilog_format: off
  localparam [7:0] TXT_PRESS[0:22] = {"P", "R", "E", "S", "S", " ",
    "A", "N", "Y", " ",
    "K", "E", "Y", " ",
    "T", "O", " ",
    "S", "T", "A", "R", "T", "!"
  };
    // verilog_format: on
  localparam PRESS_start_x = 8 * 4;
  localparam PRESS_start_y = 8 * 2;

  /////////////////
  // HIGH SCORE //
  ////////////////
  localparam [7:0] TXT_HIGHSCORE[0:9] = {"H", "I", "G", "H", " ", "S", "C", "O", "R", "E"};
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
      .ascii_char(ascii_char),
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
    ascii_char <= " ";

    // LOADING!
    /* verilator lint_off WIDTHEXPAND */
    // verilog_format: off
    if ((sy >= LOADING_start_y && sy < LOADING_start_y + CHAR_HEIGHT) && //
        (sx >= LOADING_start_x && sx < LOADING_start_x + ($size(TXT_LOADING) * CHAR_WIDTH)) && //
        (MODE == GAME_MODE_LOADING)) begin
    // verilog_format: on
      ascii_char <= TXT_LOADING[(sx-LOADING_start_x)/8];
      /* verilator lint_on WIDTHEXPAND */
    end

    // READY!
    /* verilator lint_off WIDTHEXPAND */
    // verilog_format: off
    if ((sy >= READY_start_y && sy < READY_start_y + CHAR_HEIGHT) && //
        (sx >= READY_start_x && sx < READY_start_x + ($size(TXT_READY) * CHAR_WIDTH)) && //
        (MODE == GAME_MODE_READY)) begin
    // verilog_format: on
      ascii_char <= TXT_READY[(sx-READY_start_x)/8];
      /* verilator lint_on WIDTHEXPAND */
    end
    /* verilator lint_off WIDTHEXPAND */
    // verilog_format: off
    if ((sy >= PRESS_start_y && sy < PRESS_start_y + CHAR_HEIGHT) && //
        (sx >= PRESS_start_x && sx < PRESS_start_x + ($size(TXT_PRESS) * CHAR_WIDTH)) && //
        (MODE == GAME_MODE_READY)) begin
    // verilog_format: on
      if (flash) ascii_char <= TXT_PRESS[(sx-PRESS_start_x)/8];
      else ascii_char <= " ";

      /* verilator lint_on WIDTHEXPAND */
    end

    /* verilator lint_off WIDTHEXPAND */
    // verilog_format: off
    if ((  /* sy >= HIGHSCORE_start_y && */ sy < HIGHSCORE_start_y + CHAR_HEIGHT) &&  //
        (sx >= HIGHSCORE_start_x && sx < HIGHSCORE_start_x + ($size(TXT_HIGHSCORE) * CHAR_WIDTH)) &&
        (MODE != GAME_MODE_LOADING) &&
        (MODE != GAME_MODE_READY)) begin
      // verilog_format: on
      ascii_char <= TXT_HIGHSCORE[(sx-HIGHSCORE_start_x)/8];
      /* verilator lint_on WIDTHEXPAND */
    end

    // verilog_format: off
    /* verilator lint_off WIDTHEXPAND */
    if ((sy >= BCDSCORE_start_y && sy < BCDSCORE_start_y + CHAR_HEIGHT) &&  //
        (sx >= BCDSCORE_start_x && sx < BCDSCORE_start_x + ($size(TXT_BCDSCORE) * CHAR_WIDTH)) &&
        (MODE != GAME_MODE_LOADING) &&
        (MODE != GAME_MODE_READY)) begin
      // verilog_format: on
      ascii_char <= TXT_BCDSCORE[(sx-BCDSCORE_start_x)/8];
      /* verilator lint_on WIDTHEXPAND */
    end

    /* verilator lint_off WIDTHEXPAND */
    // verilog_format: off
    if ((sy >= LOST_start_y && sy < LOST_start_y + CHAR_HEIGHT) && //
        (sx >= LOST_start_x && sx < LOST_start_x + ($size(TXT_LOST) * CHAR_WIDTH)) && //
        (MODE == GAME_MODE_FAIL)) begin
    // verilog_format: on
      ascii_char <= TXT_LOST[(sx-LOST_start_x)/8];
      /* verilator lint_on WIDTHEXPAND */
    end

    /* verilator lint_off WIDTHEXPAND */
    // verilog_format: off
    if ((sy >= RESET_start_y && sy < RESET_start_y + CHAR_HEIGHT) && //
        (sx >= RESET_start_x && sx < RESET_start_x + ($size(TXT_RESET) * CHAR_WIDTH)) && //
        (MODE == GAME_MODE_FAIL)) begin
    // verilog_format: on

      if (~flash) ascii_char <= TXT_RESET[(sx-RESET_start_x)/8];
      else ascii_char <= " ";
      /* verilator lint_on WIDTHEXPAND */
    end

    /* verilator lint_off WIDTHEXPAND */
    // ascii_char <= get_ascii_char(RESET_start_x, RESET_start_y, MODE == GAME_MODE_FAIL, TXT_RESET);
    /* verilator lint_on WIDTHEXPAND */



  end

  always_comb begin
    R = {4{pixel}};
    G = {4{pixel}};
    B = {4{pixel}};
  end


endmodule : text
