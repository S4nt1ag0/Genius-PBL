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

    // Internal signals
    logic [3:0] buttons_current;
    logic [3:0] buttons_prev;
    logic       press_detected;

     always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            decoded_output <= 2'b00;
            valid_press    <= 1'b0;
            buttons_prev   <= 4'b0000;
        end else begin
            buttons_current = {button_color_yellow, button_color_blue, button_color_red, button_color_green};

            if (player_wr) begin
                // Detect new button press
                press_detected = (buttons_current != 4'b0000) && (buttons_prev == 4'b0000);

                if (press_detected) begin
                    valid_press <= 1'b1;

                    case (buttons_current)
                        4'b0001: decoded_output <= 2'b00; // Green
                        4'b0010: decoded_output <= 2'b01; // Red
                        4'b0100: decoded_output <= 2'b10; // Blue
                        4'b1000: decoded_output <= 2'b11; // Yellow
                        default: decoded_output <= decoded_output; // No change if invalid
                    endcase
                end else begin
                    valid_press <= 1'b0; // Clear after first detection
                end

                buttons_prev <= buttons_current;
            end else begin
                // Reset logic when player_wr goes low
                valid_press  <= 1'b0;
                buttons_prev <= 4'b0000;
            end
        end
    end

endmodule