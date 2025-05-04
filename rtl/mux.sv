//------------------------------------------------------------------------------
// mux
//------------------------------------------------------------------------------
// This module performs the addition of two 4-bit numbers with a carry-in and 
// produces a 4-bit sum and a carry-out.
//
// Author: Gustavo Santiago
// Date  : Maio 2025
//------------------------------------------------------------------------------

module mux
#(parameter DATA_WIDTH = 8)
(
    input logic [DATA_WIDTH-1:0] in_a, 
    input logic [DATA_WIDTH-1:0] in_b,
    input logic sel_b,
    output logic [DATA_WIDTH-1:0] out
    );

    always_comb begin: select_data
        if(sel_b) begin
            out <= in_b;
        end else begin
            out <= in_a;
        end
    end

endmodule