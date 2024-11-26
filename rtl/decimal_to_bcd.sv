`timescale 1ns / 1ps

module decimal_to_bcd #(
    parameter BIN_WIDTH  = 8,  // Width of the binary input
    parameter BCD_DIGITS = 3   // Number of BCD digits in the output
) (
    input  logic [     BIN_WIDTH-1:0] binary,  // Binary input
    output logic [(BCD_DIGITS*4)-1:0] bcd      // BCD output
);
  integer i, j;

  always_comb begin
    // Initialize the BCD output to zero
    bcd = 0;

    // Start the Double Dabble algorithm
    for (i = BIN_WIDTH - 1; i >= 0; i--) begin
      // Step 1: Shift left all BCD digits and bring in the next binary bit
      bcd = {bcd[(BCD_DIGITS*4)-2:0], binary[i]};

      // Step 2: Adjust BCD digits (Add 3 if the digit >= 5)
      for (j = 0; j < BCD_DIGITS; j++) begin
        if (bcd[(j*4)+3-:4] >= 5) bcd[(j*4)+3-:4] = bcd[(j*4)+3-:4] + 3;
      end
    end
  end
endmodule
