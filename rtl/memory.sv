//------------------------------------------------------------------------------
// memory_module
//------------------------------------------------------------------------------
// This module performs the addition of two 4-bit numbers with a carry-in and 
// produces a 4-bit sum and a carry-out.
//
// Author: Gustavo Santiago
// Date  : Maio 2025
//------------------------------------------------------------------------------

module memory_module
#(parameter ADDR_WIDTH = 5, parameter DATA_WIDTH = 8)
(
    input logic clk,
    input logic read,
    input logic write,
    input logic [ADDR_WIDTH-1:0] addr,
    input logic [DATA_WIDTH-1:0] data_in,
    output logic [DATA_WIDTH-1:0] data_out
);

logic [DATA_WIDTH-1:0] mem_block [0:(2**ADDR_WIDTH)-1];

always_ff @(posedge clk) begin: write_or_read

if(write==1 && read == 0)
    mem_block[addr] <= data_in;
else if(write == 0 && read == 1)
    data_out <= mem_block[addr];
end
endmodule