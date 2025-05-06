//------------------------------------------------------------------------------
// counter
//------------------------------------------------------------------------------
// This module performs the addition of two 4-bit numbers with a carry-in and 
// produces a 4-bit sum and a carry-out.
//
// Author: Gustavo Santiago
// Date  : Maio 2025
//------------------------------------------------------------------------------

module counter 
#(parameter DATA_WIDTH = 8)
(
    input logic clk,
    input logic rst_n,
    input logic enable,
    output logic [DATA_WIDTH-1:0] count
    );
    
    
    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            count <= 0;
        end
        else begin
            if(enable) begin
                count <= count+1;
            end
            else begin
                count <= count;
            end
        end
                
    end
    
endmodule