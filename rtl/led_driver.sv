//------------------------------------------------------------------------------
// grn
//------------------------------------------------------------------------------
// This module performs the addition of two 4-bit numbers with a carry-in and 
// produces a 4-bit sum and a carry-out.
//
// Author: Gustavo Santiago
// Date  : Maio 2025
//------------------------------------------------------------------------------

`timescale 1ns / 1ps

module led_driver
#(parameter DATA_WIDTH = 8)
(
    input logic clk,
    input [DATA_WIDTH-1:0] data_in,
    output logic led_green,
    output logic led_blue,
    output logic led_red,
    output logic led_yellow
    );

    always_ff @(posedge clk) begin: get_data
            led_green <= 0;
            led_blue <= 0;
            led_red <= 0;
            led_yellow <= 0;

        case(data_in)
            00: led_green <= 1;
            01: led_blue <= 1;
            10: led_red <= 1;
            11: led_yellow <= 1;
        endcase
    end
endmodule