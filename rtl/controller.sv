//------------------------------------------------------------------------------
// controller (FSM)
//------------------------------------------------------------------------------
// This module performs the addition of two 4-bit numbers with a carry-in and 
// produces a 4-bit sum and a carry-out.
//
// Author: Gustavo Santiago
// Date  : Maio 2025
//------------------------------------------------------------------------------

`timescale 1ns / 1ps

module controller 
    import typedefs_pkg::*;
#(
    parameter DATA_WIDTH = 4,
    parameter DIFICULTY_WIDTH = 2,
    parameter ADDR_WIDTH = 5
)(
    input logic rst_n,
    input logic clk,                                 // clk
    input logic [DATA_WIDTH-1:0] player_input,       // Input player_input
    input logic [DIFICULTY_WIDTH-1:0] difficulty,    // Input difficulty
    input logic speed,                               // Speed input
    input logic mode,                                // mode input
    input logic start,                               // strat input
    input logic [DATA_WIDTH-1:0] sequence_item,
    input logic [ADDR_WIDTH-1:0] match_index,
    input logic [ADDR_WIDTH-1:0] sequence_index,
    output logic settings_wr,
    output logic player_wr,
    output logic mem_rd,
    output logic mem_wr,
    output logic inc_match_index,
    output logic inc_sequence_index,
    output logic inc_score,
    output logic rst_match,
    output logic rst_sequence,
    output logic rst_score,
    output logic enable_led,
    output logic update_score,
    output logic all_leds 
);

    state_t state = IDLE, next_state;
    

    always_comb begin: process_next_state
        next_state = state;
        case (state)
            IDLE: begin 
                if(start) next_state = GET_NEXT_SEQUENCE_ITEM;
            end
            GET_NEXT_SEQUENCE_ITEM: begin
                next_state = SHOW_SEQUENCE;
                if(mode && sequence_index > 1) next_state = GET_PLAYER_INPUT;
            end
            SHOW_SEQUENCE: begin
                if(match_index == sequence_index) begin 
                    next_state = EVALUATE;
                end
            end
            GET_PLAYER_INPUT: begin 
                if(player_input) next_state = COMPARISON;
            end
            COMPARISON: begin
                next_state = GET_PLAYER_INPUT;
                if(player_input != sequence_item) next_state = DEFEAT;
                else if (player_input == sequence_item && match_index == sequence_index) next_state = EVALUATE;
            end
            DEFEAT: 
                next_state = IDLE;
            EVALUATE: begin
                next_state = VICTORY;
                if(sequence_index < difficulty) next_state = GET_NEXT_SEQUENCE_ITEM;
            end
            VICTORY: next_state = IDLE;
        endcase
    end

    always_ff @(posedge clk, negedge rst_n) begin : proc_stage
        if(!rst_n) begin
            state <= IDLE;
        end else begin 
            state <= next_state;
        end
    end

    

    always_comb begin: state_decode
        settings_wr = 0;
        player_wr = 0;
        mem_rd = 0;
        mem_wr = 0;
        inc_match_index = 0;
        inc_sequence_index = 0;
        rst_match = 0;
        rst_sequence = 0;
        enable_led = 0;
        update_score = 0;

        case (state)
            IDLE: begin 
                settings_wr = 1;
                rst_match = 1;
                rst_sequence = 1;
            end
            GET_NEXT_SEQUENCE_ITEM: begin
                mem_wr = 1;
                inc_sequence_index =1;
            end
            SHOW_SEQUENCE: begin
                mem_rd = 1;
                inc_match_index = 1;
                enable_led = 1;
                if(match_index == sequence_index) begin 
                    rst_match = 1;
                end
            end
            GET_PLAYER_INPUT: begin 
                player_wr = 1;
                mem_rd = 1;
            end
            COMPARISON: begin
                inc_match_index += 1;
                if(player_input != sequence_item)begin 
                    update_score = 1;
                end
            end
            DEFEAT: 
                all_leds = 1;
            EVALUATE: begin
                rst_match = 1;
                if(sequence_index < (8<< difficulty)) begin 
                    inc_sequence_index = 1;
                end
            end
            VICTORY: begin
                all_leds = 1;
            end
        endcase   
    end

endmodule


