`timescale 1ns / 1ps

module decimal_to_bcd (
    input  logic [15:0] binary,      // 16-bit binary score input
    output logic [ 3:0] bcd   [0:3]  // 4 BCD digits to represent the binary
);

  integer i;

  always_comb begin
    // Initialize BCD binary digits to 0
    bcd[0] = 4'b0000;
    bcd[1] = 4'b0000;
    bcd[2] = 4'b0000;
    bcd[3] = 4'b0000;

    // Perform BCD conversion using Double Dabble Algorithm
    for (i = 15; i >= 0; i = i - 1) begin
      // Shift left to make room for the next bit of the binary
      if (bcd[3] >= 5) bcd[3] = bcd[3] + 3;
      if (bcd[2] >= 5) bcd[2] = bcd[2] + 3;
      if (bcd[1] >= 5) bcd[1] = bcd[1] + 3;
      if (bcd[0] >= 5) bcd[0] = bcd[0] + 3;

      // Shift all BCD digits left by 1 (equivalent to multiplying by 2)
      bcd[3] = bcd[3] << 1;
      bcd[2] = bcd[2] << 1;
      bcd[1] = bcd[1] << 1;
      bcd[0] = bcd[0] << 1;

      // Bring in the next bit from the binary
      bcd[0][0] = binary[i];
    end
  end

endmodule
