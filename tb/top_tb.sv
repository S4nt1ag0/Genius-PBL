`timescale 1ns / 1ps

module top_tb;

  // Parameters
  parameter COLOR_CODEFY_W = 2;
  parameter ADDR_WIDTH = 5;
  parameter LFSR_WIDTH = 16;

  // Inputs
  logic rst_n;
  logic clk;
  logic mode_button;
  logic [COLOR_CODEFY_W-1:0] difficulty_button;
  logic speed_button;
  logic button_color_green;
  logic button_color_red;
  logic button_color_blue;
  logic button_color_yellow;
  logic start;

  // Outputs
  logic led_red;
  logic led_green;
  logic led_blue;
  logic led_yellow;
  logic [ADDR_WIDTH-1:0] lcd_display;

  // Clock generation (100MHz)
  initial clk = 0;
  always #5 clk = ~clk;

  // Instantiate the DUT
  top #(
    .COLOR_CODEFY_W(COLOR_CODEFY_W),
    .ADDR_WIDTH(ADDR_WIDTH)
  )dut (
    .rst_n(rst_n),
    .clk(clk),
    .mode_button(mode_button),
    .difficulty_button(difficulty_button),
    .speed_button(speed_button),
    .button_color_green(button_color_green),
    .button_color_red(button_color_red),
    .button_color_blue(button_color_blue),
    .button_color_yellow(button_color_yellow),
    .start(start),
    .led_red(led_red),
    .led_green(led_green),
    .led_blue(led_blue),
    .led_yellow(led_yellow),
    .lcd_display(lcd_display)
  );

  // Task to simulate a button press with edge detection
  task automatic press_color_button(ref logic btn);
    begin
      btn = 1;       // Press button
      #30;           // Hold for enough cycles to be detected
      btn = 0;       // Release button
      #20;
      $display("Button Pressed...");
    end
  endtask

  initial begin
    // Initialize inputs
    rst_n = 0;
    mode_button = 0;
    difficulty_button = 2'b01; // Medium difficulty
    speed_button = 0;
    button_color_green = 0;
    button_color_red = 0;
    button_color_blue = 0;
    button_color_yellow = 0;
    start = 0;

    // Reset sequence
    #20;
    rst_n = 1;
    #20;

    // Test case 1: Configuration
    $display("Setting up game configuration...");
    mode_button = 1;           // Set to mando eu mode
    difficulty_button = 2'b10; // Hard difficulty
    speed_button = 1;          // Fast speed
    #30;
    
    // Start the game
    $display("Starting game...");
    start = 1;
    #20;
    start = 0;
    #30;

    // Wait for sequence display
    $display("Waiting for sequence display...");
    #20;

    // Test case 2: Correct sequence input
    $display("Simulating correct sequence input...");
    press_color_button(button_color_green);  // 00
    #50;
    press_color_button(button_color_green);  // 00
    #50;
    press_color_button(button_color_green);  // 00
    #50;
    press_color_button(button_color_red);    // 01
    #50;
    press_color_button(button_color_blue);   // 10
    #50;
    press_color_button(button_color_yellow); // 11
    #100;

    // Test case 3: Wrong input (should lead to defeat)
    $display("Simulating wrong input...");
    press_color_button(button_color_red);    // Wrong color
    #200;

    // Restart game
    $display("Restarting game...");
    start = 1;
    #20;
    start = 0;
    #100;

    // Test case 4: Mixed inputs
    $display("Simulating mixed inputs...");
    press_color_button(button_color_green);
    #30;
    press_color_button(button_color_blue);
    #30;
    press_color_button(button_color_yellow);
    #30;
    press_color_button(button_color_red);
    #100;

    // End simulation
    $display("Simulation complete");
    #100;
    $finish;
  end

  // Monitoring
  initial begin
    $timeformat(-9, 2, " ns", 10);
    $monitor("At %t: state=%s, score=%d, LEDs=%b%b%b%b", 
             $time, dut.controller.state.name(), 
             lcd_display, led_red, led_green, led_blue, led_yellow);
  end

endmodule