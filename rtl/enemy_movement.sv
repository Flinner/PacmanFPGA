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
/* verilator lint_off UNSIGNED */

module enemy_movement #(
    parameter INITIAL_MEM_FILE = "NONE",
    localparam H_MAP_WIDTH = params::pacman::H_VISIBLE_AREA,
    localparam V_MAP_HEIGHT = params::pacman::V_VISIBLE_AREA
) (
    input logic vga_pix_clk,
    input logic rst,
    input logic frame_stb,       
    input logic [8:0] x_pac,
    input logic [8:0] y_pac,
    output logic [8:0] x_blue,
    output logic [8:0] y_blue
   // output logic [8:0] x_yellow,
    //output logic [8:0] y_yellow,
   // output logic [8:0] x_pink,
    //output logic [8:0] y_pink
);

 
    logic CLK60HZ;
    assign CLK60HZ = frame_stb;

    // Map storage
    logic [3:0] MAP[0:32*36-1];
    initial begin
        $display("Loading MAP from init file '%s'.", INITIAL_MEM_FILE);
        $readmemb(INITIAL_MEM_FILE, MAP);
    end

    logic x_blue_aligned, y_blue_aligned;
    typedef enum {
     UP,
     RIGHT,
     LEFT,
     DOWN
     } direction_t;


     direction_t curr_direction;
     direction_t next_direction;
     
     logic x_aligned = x_pac[2:0] == '0;
     logic y_aligned = y_pac[2:0] == '0;
    

    logic [3:0] MAP_UP_BLUE, MAP_DOWN_BLUE, MAP_RIGHT_BLUE, MAP_LEFT_BLUE;

    always_comb begin
        MAP_UP_BLUE    = MAP[x_blue/8 + ((y_blue-1)/8)*32];
        MAP_DOWN_BLUE   = MAP[x_blue/8 + ((y_blue+8)/8)*32];
        MAP_RIGHT_BLUE  = MAP[(x_blue+8)/8 + (y_blue/8)*32];
        MAP_LEFT_BLUE   = MAP[(x_blue-8)/8 + (y_blue/8)*32];

        
    end

    ////////////////////////////
    // TARGET AND DIRECTION   //
    ////////////////////////////

    logic [8:0] target_x, target_y;
   // assign target_x = x_pac - x_red;
   // assign target_y = y_pac - y_red;

    // Direction decision based on target
    
    always_ff @(posedge vga_pix_clk) begin
            if (y_pac < y_blue )      next_direction <= UP;
            else if (y_pac > y_blue  ) next_direction <= DOWN;
            else if (x_pac > x_blue ) next_direction <= RIGHT;
            else if (x_pac < x_blue  ) next_direction <= LEFT; 
            end
        
   



    always_ff @(posedge vga_pix_clk) begin
        if (rst) begin
            // Reset positions
            x_blue   <= 8 * 15;
            y_blue   <= 8 * (4 + 10);
       
        end else begin
            unique case (curr_direction)
                UP:    if (MAP_UP_BLUE[3] == 1 && x_blue_aligned)    y_blue <= y_blue - {8'b0, CLK60HZ};
                DOWN:  if (MAP_DOWN_BLUE[3] == 1 && x_blue_aligned)  y_blue <= y_blue + {8'b0, CLK60HZ};
                RIGHT: if (MAP_RIGHT_BLUE[3] == 1 && y_blue_aligned) x_blue <= x_blue + {8'b0, CLK60HZ};
                LEFT:  if (MAP_LEFT_BLUE[3] == 1 && y_blue_aligned)  x_blue <= x_blue - {8'b0, CLK60HZ};
            endcase
        end
    end
    always_ff @(posedge vga_pix_clk) begin
        case (next_direction)
            UP: begin
                if (MAP_UP_BLUE[3] == 1 && x_blue_aligned) begin
                    curr_direction <= UP ; end
                else if (MAP_UP_BLUE[3] == 0 && x_blue_aligned)   begin 
                if (MAP_RIGHT_BLUE[3] == 1 && y_blue_aligned) curr_direction <= RIGHT;
                    else if (MAP_LEFT_BLUE[3] == 1 && y_blue_aligned) curr_direction <= LEFT;
                    else if ( MAP_DOWN_BLUE[3] == 1 && x_blue_aligned) curr_direction <= DOWN;
                end
            end
            RIGHT: begin
                if (MAP_RIGHT_BLUE[3] == 1 && y_blue_aligned) begin
                    curr_direction <= RIGHT ; end
                else if (MAP_RIGHT_BLUE[3] == 0 && y_blue_aligned)   begin
                    if (MAP_UP_BLUE[3] == 1 && x_blue_aligned) curr_direction <= UP;
                    else if (MAP_DOWN_BLUE[3] == 1 && x_blue_aligned) curr_direction <= DOWN;
                    else if (MAP_LEFT_BLUE [3] == 1 && y_blue_aligned)curr_direction <= LEFT;
                end
            end
            DOWN: begin
                if (MAP_DOWN_BLUE[3] == 1 && y_blue_aligned) begin
                curr_direction <= DOWN ; end
                else if (MAP_DOWN_BLUE[3] == 0 && y_blue_aligned)   begin
                    if (MAP_LEFT_BLUE[3] == 1 && x_blue_aligned) curr_direction <= LEFT;
                    else if (MAP_RIGHT_BLUE[3] == 1 && x_blue_aligned) curr_direction <= RIGHT;
                    else if (MAP_UP_BLUE [3] == 1 && y_blue_aligned) curr_direction <= UP;
                end
            end
            LEFT: begin
                if (MAP_LEFT_BLUE[3] == 1 && y_blue_aligned) begin
                curr_direction <= LEFT ; end
                else if (MAP_DOWN_BLUE[3] == 0 && y_blue_aligned)   begin
                     if (MAP_DOWN_BLUE[3] == 1 && x_blue_aligned) curr_direction <= DOWN;
                    else if (MAP_UP_BLUE [3] == 1 && y_blue_aligned) curr_direction <= UP;
                    else if (MAP_RIGHT_BLUE[3] == 1 && x_blue_aligned) curr_direction <= RIGHT;
                end
            end
        endcase
        if (rst) curr_direction <= RIGHT;
    end


endmodule : enemy_movement

/* verilator lint_on UNSIGNED */
