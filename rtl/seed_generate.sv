//------------------------------------------------------------------------------
// seed_counter - Counter-based Seed Generator for RNG
//------------------------------------------------------------------------------
// This module increments a counter on every clock pulse and provides its value
// as a seed when load_seed is asserted. Once load_seed is deasserted, the
// seed output remains stable.
//
// Intended usage:
// - Use during IDLE state to gather entropy from player timing or system noise.
// - When load_seed goes low, the current counter value is latched as RNG seed.
//
// Author: Gustavo Santiago
// Date  : May 2025
//------------------------------------------------------------------------------

`timescale 1ns / 1ps

module seed_generate
#(parameter SEED_WIDTH = 16)
(
    input  logic clk,             // Clock input
    input  logic rst_n,           // Active-low reset
    input  logic load_seed,       // Enable to load new seed
    output logic [SEED_WIDTH-1:0] seed_out  // Final seed for RNG
);

    // Internal counter
    logic [SEED_WIDTH-1:0] counter;
    logic [SEED_WIDTH-1:0] seed_reg;

    // Counter increments continuously
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            counter <= 0;
        else
            counter <= counter + 1;
    end

    // Load counter into seed register only when load_seed is high
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            seed_reg <= 0;
        else if (load_seed)
            seed_reg <= counter;
    end

    // Output stable seed
    assign seed_out = seed_reg;

endmodule
