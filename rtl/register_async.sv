//------------------------------------------------------------------------------
// register async
//------------------------------------------------------------------------------
// This module performs the addition of two 4-bit numbers with a carry-in and 
// produces a 4-bit sum and a carry-out.
//
// Author: Gustavo Santiago
// Date  : Maio 2025
//------------------------------------------------------------------------------

`timescale 1ns / 1ps

module register
#(parameter DATA_WIDTH = 8)
(
    input logic [DATA_WIDTH-1 :0] data,
    input logic enable,
    output logic [DATA_WIDTH-1:0] out
    );

    always_ff @(negedge data) begin: get_data
        if(enable) begin
            out <= data;
        end
    end

endmodule