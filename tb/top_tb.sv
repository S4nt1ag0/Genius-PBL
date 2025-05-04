`timescale 1ns / 1ps

module top_tb;

  // Parameters
  parameter COLOR_CODEFY_W = 2;
  parameter ADDR_WIDTH = 5;

  // Inputs
  logic rst_n;
  logic clk;
  logic mode_button;
  logic [COLOR_CODEFY_W-1:0] difficulty_button;
  logic speed_button;
  logic [COLOR_CODEFY_W-1:0] player_button;
  logic start;

  // Outputs
  logic led_red;
  logic led_green;
  logic led_blue;
  logic led_yellow;
  logic [ADDR_WIDTH-1:0] lcd_display;

  // Clock generation
  initial clk = 0;
  always #5 clk = ~clk; // 100MHz clock

  // Instantiate the DUT (Device Under Test)
  top #(
    .COLOR_CODEFY_W(COLOR_CODEFY_W),
    .ADDR_WIDTH(ADDR_WIDTH)
  ) dut (
    .rst_n(rst_n),
    .clk(clk),
    .mode_button(mode_button),
    .difficulty_button(difficulty_button),
    .speed_button(speed_button),
    .player_button(player_button),
    .start(start),
    .led_red(led_red),
    .led_green(led_green),
    .led_blue(led_blue),
    .led_yellow(led_yellow),
    .lcd_display(lcd_display)
  );

  // Task to simulate a button press
  task press_button(input logic [COLOR_CODEFY_W-1:0] btn);
    begin
      player_button = btn;
      #10;
      player_button = 0;
      #10;
    end
  endtask

  initial begin
    // Initialize inputs
    rst_n = 0;
    mode_button = 0;          // 0 = follow mode
    difficulty_button = 2'b01; // 16 steps
    speed_button = 0;         // 0 = slow
    player_button = 0;
    start = 0;

    // Reset
    #20;
    rst_n = 1;

    // Simulate configuration phase
    #10;
    mode_button = 0; // follow mode
    difficulty_button = 2'b01; // 16 steps
    speed_button = 1; // fast
    #10;

    // Start the game
    start = 1;
    #10;
    start = 0;

    // Wait for sequence to be generated/displayed
    #100;

    // Simulate user pressing buttons
    // Example: pretend user presses red, green, blue, yellow
    press_button(2'b00); // red
    press_button(2'b01); // green
    press_button(2'b10); // blue
    press_button(2'b11); // yellow

    // Wait and finish
    #200;
    $finish;
  end

endmodule
