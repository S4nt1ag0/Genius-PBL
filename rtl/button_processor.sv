//------------------------------------------------------------------------------
// controller (FSM)
//------------------------------------------------------------------------------
// This module performs the addition of two 4-bit numbers with a carry-in and 
// produces a 4-bit sum and a carry-out.
//
// Author: Gustavo Santiago
// Date  : Maio 2025
//------------------------------------------------------------------------------

module button_processor (
    input logic clk,
    input logic rst_n,
    input logic player_wr,
    input logic button_color_green,
    input logic button_color_red,
    input logic button_color_blue,
    input logic button_color_yellow,
    output logic [1:0] decoded_output,  
    output logic valid_press          
);

    logic [3:0] buttons_raw;
    logic [3:0] buttons_pressed;
    logic [3:0] buttons_prev;

    //concat buttons in array
    assign buttons_raw = {
        button_color_yellow,
        button_color_blue,
        button_color_red,
        button_color_green
    };

    //edge dection
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            buttons_prev <= 4'b0000;
            buttons_pressed <= 4'b0000;
        end 
        else if (player_wr) begin //read only when the FSM allow
            buttons_prev <= buttons_raw;
            buttons_pressed <= (~buttons_prev) & buttons_raw;
        end
        else begin
            buttons_pressed <= 4'b0000; 
        end
    end

    //convert 3:0 hotcode to 1:0
    always_comb begin
        valid_press = (buttons_pressed != 4'b0000) && ($countones(buttons_pressed) == 1);

        case (1'b1)
            buttons_pressed[0]: decoded_output = 2'b00;  // green
            buttons_pressed[1]: decoded_output = 2'b01;  // red
            buttons_pressed[2]: decoded_output = 2'b10;  // blue
            buttons_pressed[3]: decoded_output = 2'b11;  // yellow
            default: decoded_output = 2'bxx;
        endcase
    end

endmodule