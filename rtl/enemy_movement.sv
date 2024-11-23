`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/19/2024 05:37:25 PM
// Design Name: 
// Module Name: enemy_movement
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Controls the movement of enemies (monsters) in a Pac-Man-like game.
// 
// Dependencies: Map file for initialization and a VGA clock for timing.
// 
//////////////////////////////////////////////////////////////////////////////////

`ifdef VERILATOR
`include "rtl/params.sv"
`endif

module enemy_movement #(
    parameter INITIAL_MEM_FILE = "NONE",
    localparam H_MAP_WIDTH = params::pacman::H_VISIBLE_AREA,
    localparam V_MAP_HEIGHT = params::pacman::V_VISIBLE_AREA
) (
    input logic vga_pix_clk,
    input logic rst,
    input logic frame_stb,          // 60Hz frame signal for consistent movement
    input logic [8:0] x_pac,
    input logic [8:0] y_pac,
    output logic [8:0] x_red,
    output logic [8:0] y_red,
    output logic [8:0] x_blue,
    output logic [8:0] y_blue,
    output logic [8:0] x_yellow,
    output logic [8:0] y_yellow,
    output logic [8:0] x_pink,
    output logic [8:0] y_pink
);

    ///////////////////////
    // CLOCK AND MAP INIT //
    ///////////////////////
    logic CLK60HZ;
    assign CLK60HZ = frame_stb;

    // Map storage
    logic [3:0] MAP[0:32*36-1];
    initial begin
        $display("Loading MAP from init file '%s'.", INITIAL_MEM_FILE);
        $readmemb(INITIAL_MEM_FILE, MAP);
    end

    ////////////////////////////
    // POSITION AND DIRECTION //
    ////////////////////////////

    // Aligned flags for movement (monsters align to 8-pixel grid)
    logic x_red_aligned, y_red_aligned;
    logic x_blue_aligned, y_blue_aligned;
    logic x_yellow_aligned, y_yellow_aligned;
    logic x_pink_aligned, y_pink_aligned;

    // Direction type
    typedef enum { UP, RIGHT, DOWN, LEFT } direction_t;

    // Direction variables for the red monster (similar for others if needed)
    direction_t curr_direction, next_direction;

    //////////////////////
    // NEIGHBOR CHECKS  //
    //////////////////////

    // Red monster map surroundings
    logic [3:0] MAP_UP_RED, MAP_DOWN_RED, MAP_RIGHT_RED, MAP_LEFT_RED;

    always_comb begin
        MAP_UP_RED    = MAP[x_red/8 + ((y_red-1)/8)*32];
        MAP_DOWN_RED  = MAP[x_red/8 + ((y_red+8)/8)*32];
        MAP_RIGHT_RED = MAP[(x_red+8)/8 + (y_red/8)*32];
        MAP_LEFT_RED  = MAP[(x_red-8)/8 + (y_red/8)*32];

        // Alignment checks
        x_red_aligned    = (x_red[2:0] == 0);
        y_red_aligned    = (y_red[2:0] == 0);
    end

    ////////////////////////////
    // TARGET AND DIRECTION   //
    ////////////////////////////

    logic [8:0] target_x, target_y;
    assign target_x = x_pac - x_red;
    assign target_y = y_pac - y_red;

    // Direction decision based on target
    always_ff @(posedge vga_pix_clk) begin
        if (rst) begin
            curr_direction <= RIGHT;  // Default direction
        end else begin
            if (target_y < 0)       next_direction <= UP;
            else if (target_y > 0) next_direction <= DOWN;
            else if (target_x > 0) next_direction <= RIGHT;
            else if (target_x < 0) next_direction <= LEFT;
        end
    end

    /////////////////////////////
    // MOVEMENT LOGIC FOR RED  //
    /////////////////////////////

    always_ff @(posedge vga_pix_clk) begin
        if (rst) begin
            // Reset positions
            x_red <= 8 * 15;
            y_red <= 8 * (4 + 10);
        end else begin
            unique case (curr_direction)
                UP:    if (MAP_UP_RED[3] && x_red_aligned)    y_red <= y_red - {8'b0, CLK60HZ};
                DOWN:  if (MAP_DOWN_RED[3] && x_red_aligned)  y_red <= y_red + {8'b0, CLK60HZ};
                RIGHT: if (MAP_RIGHT_RED[3] && y_red_aligned) x_red <= x_red + {8'b0, CLK60HZ};
                LEFT:  if (MAP_LEFT_RED[3] && y_red_aligned)  x_red <= x_red - {8'b0, CLK60HZ};
            endcase
            curr_direction <= next_direction;  // Update direction
        end
    end
  /*
  always_ff @(posedge vga_pix_clk) begin
        case (curr_direction)
            UP: begin
                if (MAP_UP_RED[3] == 1 && x_red_aligned) begin
                    curr_direction <= UP ; end
                else if (MAP_UP_RED[3] == 0 && x_red_aligned)   begin 
                if (MAP_RIGHT_RED[3] == 1 && y_red_aligned) curr_direction <= RIGHT;
                    else if (MAP_LEFT_RED[3] == 1 && y_red_aligned) curr_direction <= LEFT;
                    else if ( MAP_DOWN_RED[3] == 1 && x_red_aligned) curr_direction <= DOWN;
                end
            end
            RIGHT: begin
                if (MAP_RIGHT_RED[3] == 1 && y_red_aligned) begin
                    curr_direction <= RIGHT ; end
                else if (MAP_RIGHT_RED[3] == 0 && y_red_aligned)   begin
                    if (MAP_UP_RED[3] == 1 && x_red_aligned) curr_direction <= UP;
                    else if (MAP_DOWN_RED[3] == 1 && x_red_aligned) curr_direction <= DOWN;
                    else if (MAP_LEFT_RED [3] == 1 && y_red_aligned)curr_direction <= LEFT;
                end
            end
            DOWN: begin
                if (MAP_DOWN_RED[3] == 1 && y_red_aligned) begin
                curr_direction <= DOWN ; end
                else if (MAP_DOWN_RED[3] == 0 && y_red_aligned)   begin
                    if (MAP_LEFT_RED[3] == 1 && x_red_aligned) curr_direction <= LEFT;
                    else if (MAP_RIGHT_RED[3] == 1 && x_red_aligned) curr_direction <= RIGHT;
                    else if (MAP_UP_RED [3] == 1 && y_red_aligned) curr_direction <= UP;
                end
            end
            LEFT: begin
                if (MAP_LEFT_RED[3] == 1 && y_red_aligned) begin
                curr_direction <= LEFT ; end
                else if (MAP_DOWN_RED[3] == 0 && y_red_aligned)   begin
                     if (MAP_DOWN_RED[3] == 1 && x_red_aligned) curr_direction <= DOWN;
                    else if (MAP_UP_RED [3] == 1 && y_red_aligned) curr_direction <= UP;
                    else if (MAP_RIGHT_RED[3] == 1 && x_red_aligned) curr_direction <= RIGHT;
                end
            end
        endcase
        if (rst) curr_direction <= RIGHT;
    end*/

endmodule : enemy_movement
