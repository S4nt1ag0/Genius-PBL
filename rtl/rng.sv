//------------------------------------------------------------------------------
// rng - 2-bit Random Number Generator
//------------------------------------------------------------------------------
// This module generates a 2-bit pseudo-random number using a seed provided by 
// the user. The idea is to improve randomness by initializing a 16-bit counter 
// with a seed value that can be derived from user interaction timing, such as 
// the number of clock cycles it takes for the user to press a button.
//
// Functionality:
// - Accepts a clock pulse (clk) and a seed input (e.g., from a timer).
// - Uses a 16-bit linear feedback shift register (LFSR) to generate pseudo-
//   random sequences.
// - Outputs only the 2 least significant bits (LSBs) of the internal register.
//
// Notes:
// - The seed should be provided once at startup or reset for good randomness.
//
// Author : Gustavo Santiago  
// Date   : May 2025
//------------------------------------------------------------------------------

`timescale 1ns / 1ps

module rng
#(
    parameter LFSR_WIDTH = 16,
    parameter DATA_OUT_WIDTH = 2
)
(
    input  logic                                  clk,     // Clock input
    input  logic [LFSR_WIDTH-1:0]                seed,    // Seed input
    input  logic                            load_seed, // Load seed when high
    output logic [DATA_OUT_WIDTH-1:0]             out      // 2-bit pseudo-random output
);

    logic [LFSR_WIDTH-1:0] lfsr;


    always_ff @(posedge clk) begin
        if (load_seed) begin
                lfsr <= seed;
            end else begin
                lfsr <= {lfsr[LFSR_WIDTH-2:0], lfsr[LFSR_WIDTH-1] ^ lfsr[13]};
            end
    end

    // Output the 2 least significant bits
    assign out = lfsr[DATA_OUT_WIDTH-1:0];

endmodule
