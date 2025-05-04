//------------------------------------------------------------------------------
// genius Game
//------------------------------------------------------------------------------
// This top module represents the Simon Game (known as Genius in Brazil). The game consists of an interface with 3
// configuration buttons: speed (fast, slow), mode (command, follow), and difficulty level (8, 16, or 32 steps). 
//There is also a start button that begins the game. The game features 4 colored LEDs, each corresponding to a button. 
//During gameplay, the LEDs light up in a specific sequence that the player must memorize and repeat by pressing the matching buttons.
//
//In 'follow' mode, the system generates a sequence for the player to reproduce. In 'command' mode, the player inputs a sequence that must be repeated by another 
//player or system. The speed setting affects how quickly the sequence is displayed, and the difficulty setting determines the length of the sequence.

//If the player successfully reproduces the sequence, the game continues with a longer sequence. 
//If an error is made, the game can either restart or display a failure indicator, depending on the implementation. 
//This module can be implemented on platforms such as FPGAs or microcontrollers, and is useful for testing memory and reflexes.
//
// Author: Gustavo Santiago
// Date  : Maio 2025
//------------------------------------------------------------------------------

`timescale 1ns / 1ps

module top
import typedefs_pkg::*;
#(
    parameter COLOR_CODEFY_W = 2,
    parameter ADDR_WIDTH = 5
)
(
    input logic rst_n,
    input logic clk,
    input logic mode_button,
    input logic [COLOR_CODEFY_W-1:0] difficulty_button,
    input logic speed_button,
    input logic [COLOR_CODEFY_W-1:0] player_button,
    input logic start,
    output logic led_red,
    output logic led_green,
    output logic led_blue,
    output logic led_yellow,
    output logic [ADDR_WIDTH-1:0] lcd_display
);


//memory
logic mem_rd;
logic mem_wr;
logic [COLOR_CODEFY_W-1:0] new_sequence_item;
logic [COLOR_CODEFY_W-1:0] sequence_item;
logic [ADDR_WIDTH-1:0] addr;

//registers
logic mode;
logic [COLOR_CODEFY_W-1:0] difficulty;
logic speed;
logic [COLOR_CODEFY_W-1:0] player_input;

//rng
logic [COLOR_CODEFY_W-1:0] random_out;
logic [15:0] seed_value;
logic load_seed; 

//counters
logic rst_sequence_counter;
logic [ADDR_WIDTH-1:0]sequence_index;
logic inc_sequence_index;

logic rst_match_counter;
logic [ADDR_WIDTH-1:0]match_index;
logic inc_match_index;

logic rst_score;
logic inc_score;

//fsm
logic settings_wr;
logic player_wr;
logic addr_mux;
logic load_ac;
logic load_ir;
logic load_pc;
logic inc_pc;

memory_module #(.ADDR_WIDTH(ADDR_WIDTH),.DATA_WIDTH(COLOR_CODEFY_W)) memory
(
    .clk      (clk      ),
    .read     (mem_rd     ),
    .write    (mem_wr    ),
    .addr     (addr     ),
    .data_in  (new_sequence_item  ),
    .data_out (sequence_item )
);


register mode_register(
    .data(mode_button),
    .enable(settings_wr),
    .out(mode)
);

register #(.DATA_WIDTH(COLOR_CODEFY_W)) difficulty_register(
    .data(difficulty_button),
    .enable(settings_wr),
    .out(difficulty)
);

register speed_register(
    .data(speed_button),
    .enable(settings_wr),
    .out(speed)
);

register #(.DATA_WIDTH(COLOR_CODEFY_W)) player_input_register(
    .data(player_button),
    .enable(player_wr),
    .out(player_input)
);


seed_generate #(.SEED_WIDTH(LFSR_WIDTH)) seed_gen (
    .clk(clk),
    .rst_n(rst_n),
    .load_seed(load_seed),
    .seed_out(seed_value)
);

rng #(.LFSR_WIDTH(LFSR_WIDTH), .DATA_OUT_WIDTH(COLOR_CODEFY_W)) rng
(
    .clk(clk),
    .seed(seed_value),
    .load_seed(load_seed),
    .out(random_out)
);

mux #(.DATA_WIDTH(COLOR_CODEFY_W)) mux_sequence_input (
    .in_a(random_out),
    .in_b(player_input),
    .sel_b(mode),
    .out(new_sequence_item)
);

counter #(.DATA_WIDTH(ADDR_WIDTH)) sequence_counter (
    .clk(clk),
    .rst_n(rst_sequence_counter),
    .enable(inc_sequence_index),
    .count(sequence_index)
);

counter #(.DATA_WIDTH(ADDR_WIDTH)) match_counter (
    .clk(clk),
    .rst_n(rst_match_counter),
    .enable(inc_match_index),
    .count(match_index)
);

counter #(.DATA_WIDTH(ADDR_WIDTH)) score_counter (
    .clk(clk),
    .rst_n(rst_score),
    .enable(inc_score),
    .count(lcd_display)
);

mux #(.DATA_WIDTH(ADDR_WIDTH)) mux_addr (
    .in_a(match_index),
    .in_b(sequence_index),
    .sel_b(addr_mux),
    .out(addr)
);

controller #(.DIFICULTY_WIDTH(COLOR_CODEFY_W), .DATA_WIDTH(COLOR_CODEFY_W), .ADDR_WIDTH(ADDR_WIDTH)) controller(
    .rst_n(rst_n),
    .clk(clk),                 
    .player_input(player_input),
    .difficulty(difficulty), 
    .speed(speed),
    .mode(mode),
    .start(start),
    .sequence_item(sequence_item),
    .match_index(match_index),
    .sequence_index(sequence_index),
    .settings_wr(settings_wr),
    .player_wr(player_wr),
    .mem_rd(mem_rd),
    .mem_wr(mem_wr),
    .inc_match_index(inc_match_index),
    .inc_sequence_index(inc_sequence_index),
    .inc_score(inc_score),
    .rst_match(rst_match),
    .rst_sequence(rst_sequence),
    .rst_score(rst_score),
    .enable_led(enable_led),
    .all_leds(all_leds),
    .load_seed(load_seed)
);

endmodule