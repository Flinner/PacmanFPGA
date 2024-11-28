`timescale 1ns / 1ps

// chatGPTed.
module decimal_to_bcd (
    input  logic [15:0] binary,      // 16-bit binary input
    output logic [ 3:0] bcd   [0:3]  // 4 BCD digits (each 4 bits)
);

  integer i;

  always_comb begin
    // Initialize BCD digits to 0
    bcd[0] = 4'b0;
    bcd[1] = 4'b0;
    bcd[2] = 4'b0;
    bcd[3] = 4'b0;

    // Process the 16-bit binary input
    for (i = 15; i >= 0; i = i - 1) begin
      // Shift the BCD digits left by 1 to make room for the next bit
      bcd[0] = bcd[0] << 1;
      bcd[1] = bcd[1] << 1;
      bcd[2] = bcd[2] << 1;
      bcd[3] = bcd[3] << 1;

      // Insert the next binary bit into the LSB of bcd[0]
      bcd[0][0] = binary[i];

      // BCD correction: If any digit > 4, add 3 to correct the BCD digit
      if (bcd[0] > 4) bcd[0] = bcd[0] + 3;
      if (bcd[1] > 4) bcd[1] = bcd[1] + 3;
      if (bcd[2] > 4) bcd[2] = bcd[2] + 3;
      if (bcd[3] > 4) bcd[3] = bcd[3] + 3;
    end
  end

endmodule
