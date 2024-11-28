`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/19/2024 05:37:25 PM
// Design Name: 
// Module Name: drawing_logic
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments: This module is pipelined at stage 2,
//                      not that it matters, due to abstraction.
// 
//////////////////////////////////////////////////////////////////////////////////
`ifdef VERILATOR
`include "rtl/params.sv"
`include "rtl/common_defines.svh"
`else
`include "params.sv"
`include "common_defines.svh"
`endif

// This game only sees 224x288 display. It doesn't care about the rest,
//  it is fine to give random output to save on logic
// The game is 28*36 blocks
module pacman_game #(
    // MAP PARAMS
    localparam H_MAP_WIDTH = params::pacman::H_VISIBLE_AREA,
    localparam V_MAP_HEIGHT = params::pacman::V_VISIBLE_AREA,
    localparam MAP_BLOCK_SIZE = 8,
    // probably there is a way to make verilator path finding match vivado, not worth the effort to investigate
`ifdef VERILATOR
    localparam MAP_F = "rtl/mem/map.mem",
`else
    localparam MAP_F = "mem/map.mem",
`endif

    // PACMAN PARAMS
    parameter SPRITE_WIDTH  = 8,
    parameter SPRITE_HEIGHT = 8

) (
    output logic [3:0] R,
    output logic [3:0] G,
    output logic [3:0] B,
    // there is an important distnction between `vga_pix_clk` and `game_pix_stb`
    // vga_pix_clk will "clock" on each physical vga pixel drawing
    // game_pix_stb will STROBE on each virtual game pixel
    // this is because the game is upscaled/downscaled, and its logic is
    // decoupled from the physical vga display
    input logic vga_pix_clk,
    input logic game_pix_stb,  // 1 stage pipeline
    input logic clk,
    input logic rst,
    // this strobes on each new frame. i.e, sx==sy==00
    input logic frame_stb,  // 1 stage pipeline
    input logic [$clog2(H_MAP_WIDTH)-1:0] sx,  // 1 stage pipeline
    input logic [$clog2(V_MAP_HEIGHT)-1:0] sy,  // 1 stage pipeline
    input logic BTNU,
    input logic BTND,
    input logic BTNR,
    input logic BTNL,
    input logic display_enabled  // 1 stage pipeline
);

  //////////////////////
  // PIPELINING START //
  //////////////////////
  logic [$clog2(H_MAP_WIDTH)-1:0] sx1;
  logic [$clog2(V_MAP_HEIGHT)-1:0] sy1;
  logic display_enabled1;  // 1 stage pipelined
  logic frame_stb1;  // 1 stage pipelined
  logic game_pix_stb1;  // 1 stage pipelined
  always_ff @(posedge vga_pix_clk) begin
    sx1 <= sx;
    sy1 <= sy;
    display_enabled1 <= display_enabled;
    frame_stb1 <= frame_stb;
    game_pix_stb1 <= game_pix_stb;
  end

  ////////////////////
  // PIPELINING END //
  ////////////////////


  ////////////////////
  // GAME LOGIC FSM //
  ////////////////////

  game_mode_t gm;

  always_ff @(posedge vga_pix_clk) begin
    if (rst) begin
      gm <= GAME_MODE_LOADING;
      loading_timer_start <= ~loading_timer_start;
      $display("MODE IS LOADING!!");
    end

    case (gm)
      // exits after timer
      GAME_MODE_LOADING: begin
        if (loading_stb) begin
          // TODO: loading screen
        end else begin
          gm <= GAME_MODE_READY;
          // $display("MODE IS WELCOME SCREEN!!");
          // welcome_timer_start <= ~welcome_timer_start;
        end

      end

      // exits after timer
      GAME_MODE_WELCOME_SCREEN: begin
        if (welcome_stb) begin
          // TODO: no welcome
          gm <= GAME_MODE_READY;
        end else begin
          gm <= GAME_MODE_READY;
          $display("MODE IS READY!!");
        end
      end

      // exits after any key press
      GAME_MODE_READY: begin
        if (BTNU || BTND || BTNL || BTNR) begin
          gm <= GAME_MODE_GAME_PLAY;
          $display("MODE IS GAME_PLAY!!");
        end
      end

      // exits with LOSING/WINNING
      GAME_MODE_GAME_PLAY: begin
        if (collided_with_enemy) begin
          gm <= GAME_MODE_FAIL;
          fail_timer_start <= ~fail_timer_start;
        end
        if (score >= params::map::candy_count) gm <= GAME_MODE_WIN;
      end

      GAME_MODE_BLUE_GHOST_MODE: ;

      GAME_MODE_FAIL:
      if (fail_stb) begin
      end else begin
        gm <= GAME_MODE_LOADING;
      end

      GAME_MODE_FINISH: ;

    endcase
  end

  ////////////
  // TIMERS //
  ////////////
  logic loading_stb;
  logic loading_timer_start;
  strobe_gen #(  /**AUTOINSTPARAM*/
      // Parameters
`ifdef VERILATOR
      .CLOCK_FREQ_HZ(1_000_000),
`endif
      .STROBE_TIME_S(1)
  ) loading_timer (  /**AUTOINST*/
      // Outputs
      .strobe(loading_stb),
      // Inputs
      .clk   (vga_pix_clk),
      .start (loading_timer_start)
  );

  logic welcome_stb;
  logic welcome_timer_start;
  strobe_gen #(  /**AUTOINSTPARAM*/
      // Parameters
`ifdef VERILATOR
      .CLOCK_FREQ_HZ(1_000_000),
`endif
      .STROBE_TIME_S(1)
  ) welcome_timer (  /**AUTOINST*/
      // Outputs
      .strobe(welcome_stb),
      // Inputs
      .clk   (vga_pix_clk),
      .start (welcome_timer_start)
  );


  logic fail_stb;
  logic fail_timer_start;
  strobe_gen #(  /**AUTOINSTPARAM*/
      // Parameters
`ifdef VERILATOR
      .CLOCK_FREQ_HZ(1_000_000),
`endif
      .STROBE_TIME_S(1)
  ) fail_timer (  /**AUTOINST*/
      // Outputs
      .strobe(fail_stb),
      // Inputs
      .clk   (vga_pix_clk),
      .start (fail_timer_start)
  );

  //////////////////////////
  // SCORE AND SCOREBOARD //
  //////////////////////////
  // TODO Scoreboard!
  logic [15:0] score;
  always_ff @(posedge vga_pix_clk) begin
    if (rst) score <= 0;
    else if (ate_candy_stb) begin
      score <= score + 1;
      $display("Score: %d", score + 1);
    end
  end


  //////////////
  // MOVEMENT //
  //////////////
  logic [8:0] x_pac;
  logic [8:0] y_pac;

  logic h_flip;
  logic v_flip;

  pacman_movement #(
      .INITIAL_MEM_FILE(MAP_F)
  ) pacman_movement (  /**AUTOINST*/
      // Outputs
      .x_pac      (x_pac),
      .y_pac      (y_pac),
      .h_flip     (h_flip),
      .v_flip     (v_flip),
      // Inputs
      .vga_pix_clk(vga_pix_clk),
      .rst        (rst),
      .frame_stb  (frame_stb1 & gm == GAME_MODE_GAME_PLAY),
      .sx         (sx),
      .sy         (sy),
      .BTNU       (BTNU),
      .BTND       (BTND),
      .BTNR       (BTNR),
      .BTNL       (BTNL)
      // .MAP        (MAP  /*[3:0].[0:32*36-1]*/)
  );

  ////////////////////////////
  // CANDY and POWER COOKIE //
  ////////////////////////////
  // this is the drawing beam's map tile
  logic [3:0] map_drawing_tile;
  // this is pacman's map tile
  logic [3:0] map_pacman_tile;

  // strobe when eating a (power)cookie for one vga_pix_clk
  logic ate_candy_stb;
  logic ate_power_cookie_stb;
  cookie_candy cookie_candy (  /**AUTOINST*/
      // Outputs
      .ate_candy_stb       (ate_candy_stb),
      .ate_power_cookie_stb(ate_power_cookie_stb),
      // Inputs
      .map_pacman_tile     (map_pacman_tile),
      .vga_pix_clk         (vga_pix_clk),
      .rst                 (rst)
  );


  // PORT A:
  //   used to read tile to draw, based on sx/sy
  // PORT B:
  //   used to read tile of pacman now, based on x_pac, y_pac
  dual_port_bram_with_rst #(
      // Parameters
      .DATA_WIDTH(4),
      .DATA_DEPTH(32 * 36),
      .INITIAL_MEM_FILE(MAP_F)
  ) candy_and_map_memory (
      // Outputs
      .douta(map_drawing_tile),
      .doutb(map_pacman_tile),
      // Inputs
      .clk(vga_pix_clk),
      .soft_rst(rst),
      .wea('0),  // never write here, read only port
      .web(ate_candy_stb | ate_power_cookie_stb),
      /* verilator lint_off WIDTHEXPAND */
      // PIPELINE - 1: this returns data one clk later
      .addra((sx / 8) + (sy / 8) * 32),
      // I think x_pac doesn't need the -1 pipeline
      // I believe this is fine, since x_pac/y_pac change values at new frames
      // by the time they change 100s of clks has passed
      .addrb((x_pac / 8) + (y_pac / 8) * 32),
      /* verilator lint_on WIDTHEXPAND */
      .dia('b0),  // never write here :)
      .dib('b1000)
  );

  ////////////////////////
  // ENEMIES            //
  ////////////////////////
  logic [8:0] x_red;
  logic [8:0] y_red;
  logic [8:0] x_blue;
  logic [8:0] y_blue;
  logic [8:0] x_orange;
  logic [8:0] y_orange;
  logic [8:0] x_pink;
  logic [8:0] y_pink;

  enemy_movement #(
      /**AUTOINSTPARAM*/
      // Parameters
      .INITIAL_MEM_FILE(MAP_F)
  ) enemy_movement (
      /**AUTOINST*/
      // Outputs
      .x_blue     (x_blue),
      .y_blue     (y_blue),
      // Inputs
      .vga_pix_clk(vga_pix_clk),
      .rst        (rst),
      .frame_stb  (frame_stb1 & gm == GAME_MODE_GAME_PLAY),
      .x_pac      (x_pac),
      .y_pac      (y_pac)
  );

  red_monster_mov #(
      /**AUTOINSTPARAM*/
      // Parameters
      .INITIAL_MEM_FILE(MAP_F)
  ) red_mov (
      /**AUTOINST*/
      // Outputs
      .x_red      (x_red),
      .y_red      (y_red),
      // Inputs
      .vga_pix_clk(vga_pix_clk),
      .rst        (rst),
      .frame_stb  (frame_stb1 & gm == GAME_MODE_GAME_PLAY),
      .x_pac      (x_pac),
      .y_pac      (y_pac)
  );
  orange_monster_move #(
      /**AUTOINSTPARAM*/
      // Parameters
      .INITIAL_MEM_FILE(MAP_F)
  ) orange_mov (
      /**AUTOINST*/
      // Outputs
      .x_orange   (x_orange),
      .y_orange   (y_orange),
      // Inputs
      .vga_pix_clk(vga_pix_clk),
      .rst        (rst),
      .frame_stb  (frame_stb1 & gm == GAME_MODE_GAME_PLAY),
      .x_pac      (x_pac),
      .y_pac      (y_pac)
  );

  pink_monster_mov #(
      /**AUTOINSTPARAM*/
      // Parameters
      .INITIAL_MEM_FILE(MAP_F)
  ) pink_mov (
      /**AUTOINST*/
      // Outputs
      .x_pink     (x_pink),
      .y_pink     (y_pink),
      // Inputs
      .vga_pix_clk(vga_pix_clk),
      .rst        (rst),
      .frame_stb  (frame_stb1 & gm == GAME_MODE_GAME_PLAY),
      .x_pac      (x_pac),
      .y_pac      (y_pac)
  );

  ///////////////
  // COLLISION //
  ///////////////
  logic collided_with_enemy;
  assign collided_with_enemy = (x_pac == x_red    && y_pac == y_red)    || 
                               (x_pac == x_blue   && y_pac == y_blue)   || 
                               (x_pac == x_orange && y_pac == y_orange) || 
                               (x_pac == x_pink   && y_pac == y_pink);



  ////////////////////////
  // SPRITES AND COLORS //
  ////////////////////////

  logic [3:0] R_enemy;
  logic [3:0] G_enemy;
  logic [3:0] B_enemy;


  // Enemies!
  enemy_sprite enemy_sprite (  /**AUTOINST*/
      // Outputs
      .clk     (vga_pix_clk),
      .rst     (rst),
      .R       (R_enemy),
      .G       (G_enemy),
      .B       (B_enemy),
      // Inputs
      .x_red   (x_red),
      .y_red   (y_red),
      .x_blue  (x_blue),
      .y_blue  (y_blue),
      .x_orange(x_orange),
      .y_orange(y_orange),
      .x_pink  (x_pink),
      .y_pink  (y_pink),
      .sx      (sx1),
      .sy      (sy1)
  );


  // PACMAN COLOR
  logic [11:0] color;
  logic [ 3:0] R_PAC;
  logic [ 3:0] G_PAC;
  logic [ 3:0] B_PAC;

  // Pacman!
  pacman_sprite pacman_sprite (  /**AUTOINST*/
      // Outputs
      .clk   (vga_pix_clk),
      .rst   (rst),
      .R     (R_PAC),
      .G     (G_PAC),
      .B     (B_PAC),
      // Inputs
      .x_pac (x_pac),
      .y_pac (y_pac),
      .sx    (sx1),
      .sy    (sy1),
      .h_flip(h_flip),
      .v_flip(v_flip)
  );


  logic [3:0] R_map;
  logic [3:0] G_map;
  logic [3:0] B_map;

  map_sprite map_sprite (
      sx1[2:0],
      sy1[2:0],
      map_drawing_tile,
      R_map,
      G_map,
      B_map
  );

  //////////
  // TEXT //
  //////////

  logic [3:0] R_txt;
  logic [3:0] G_txt;
  logic [3:0] B_txt;

  text text (  /**AUTOINST*/
      // Outputs
      .R   (R_txt),
      .G   (G_txt),
      .B   (B_txt),
      // Inputs
      .clk(vga_pix_clk),
      .sx  (sx),
      .sy  (sy),
      .score(score),
      .MODE(gm)
  );

  // TODO: remove useless check, since we check the screen on the RGB anyway
  always_comb begin
    // if (game_pix_stb1) begin
    if (gm == GAME_MODE_LOADING || gm == GAME_MODE_FAIL) begin
      R = R_txt;  // TODO: change to 32!!
      G = G_txt;
      B = B_txt;
    end else begin
      R = R_txt | R_map | R_PAC | R_enemy;  // TODO: change to 32!!
      G = G_txt | G_map | G_PAC | G_enemy;
      B = B_txt | B_map | B_PAC | B_enemy;
    end
    // end else begin

    //   R <= '0;
    //   G <= '0;
    //   B <= '0;
  end

endmodule
