`timescale 1ns / 1ps
`ifdef VERILATOR
`include "rtl/common_defines.svh"
`else
`include "common_defines.svh"
`endif

module audio (
    input  sound_t sound_type,
    output logic   pwm,
    output logic   en
);



endmodule : audio
