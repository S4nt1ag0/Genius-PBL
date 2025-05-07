//------------------------------------------------------------------------------
// controller (FSM)
//------------------------------------------------------------------------------
//This is a game controller finite state machine with 8 states that manages a sequence-matching game. 
//It starts in IDLE, progresses through sequence display (GET_NEXT_SEQUENCE_ITEM, SHOW_SEQUENCE, CLEAN_SEQUENCE), 
//then player input handling (GET_PLAYER_INPUT, COMPARISON), and finally evaluates results (EVALUATE, VICTORY/DEFEAT). 
//The FSM controls memory operations, LED displays, score tracking, and game flow based on player inputs, difficulty settings, and sequence matching. 
//It uses synchronous state transitions with asynchronous reset and generates various control signals (mem_rd, enable_led, etc.) depending on the current state. 
//The state machine supports different game modes and difficulty levels while managing the complete game lifecycle from start to victory/defeat conditions.
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
    input logic button_player_pressed,
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
    output logic all_leds,
    output logic load_seed,
    output logic mux_addr_sequence
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
                if(match_index > sequence_index) begin 
                    next_state = CLEAN_SEQUENCE;
                end
            end
            CLEAN_SEQUENCE: begin
                next_state = GET_PLAYER_INPUT;
            end
            GET_PLAYER_INPUT: begin 
                if(button_player_pressed) next_state = COMPARISON;
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
                if(sequence_index < (8<< difficulty)) next_state = GET_NEXT_SEQUENCE_ITEM;
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
        enable_led = 0;
        inc_score = 0;
        load_seed = 0;
        mux_addr_sequence = 0;
        rst_match = 1;
        rst_sequence = 1;
        case (state)
            IDLE: begin 
                settings_wr = 1;
                rst_match = 0;
                rst_sequence = 0;
                load_seed = 1;
            end
            GET_NEXT_SEQUENCE_ITEM: begin
                mem_wr = 1;
                mux_addr_sequence = 1;
            end
            SHOW_SEQUENCE: begin
                mem_rd = 1;
                inc_match_index = 1;
                enable_led = 1;
            end
            CLEAN_SEQUENCE: begin 
                rst_match <= 0;
            end
            GET_PLAYER_INPUT: begin 
                player_wr = 1;
                mem_rd = 1;
            end
            COMPARISON: begin
                inc_match_index = 1;
                if(player_input != sequence_item)begin 
                    inc_score = 1;
                end
            end
            DEFEAT: 
                all_leds = 1;
            EVALUATE: begin
                rst_match = 0;
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