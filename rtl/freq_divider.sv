`timescale 1ns / 1ps

module freq_divider #(
    parameter int CLK_FREQ = 100000000
)(
    input  logic clk,         
    input  logic rst_n,       
    input  logic select_2s,    // 0 = 1s, 1 = 2s
    output logic time_pulse    
);

    localparam int COUNT_1S = CLK_FREQ - 1;
    localparam int COUNT_2S = (2 * CLK_FREQ) - 1;
    
    logic [32:0] counter;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= '0;          
            time_pulse <= 1'b0;
        end
        else begin
            if ((!select_2s && (counter == COUNT_1S)) || 
                (select_2s && (counter == COUNT_2S))) begin
                counter <= '0;
                time_pulse <= 1'b1;
            end
            else begin
                counter <= counter + 1;
                time_pulse <= 1'b0;
            end
        end
    end

endmodule