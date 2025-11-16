`timescale 1ns/1ps

module tb_pipelined_moving_average;

  localparam DATA_WIDTH = 16;
  localparam CLK_PERIOD = 10;
  localparam PIPELINE_LATENCY = 4; // DUT delay cycles

  logic clk, rst_n;
  logic valid_in;
  logic [DATA_WIDTH-1:0] data_in;
  logic valid_out;
  logic [DATA_WIDTH-1:0] data_out;

  pipelined_moving_average #(.DATA_WIDTH(DATA_WIDTH)) dut (
    .clk(clk),
    .rst_n(rst_n),
    .valid_in(valid_in),
    .data_in(data_in),
    .valid_out(valid_out),
    .data_out(data_out)
  );

  // Clock
  always #(CLK_PERIOD/2) clk = ~clk;

  // Task to send one sample
  task send_sample(input [DATA_WIDTH-1:0] sample);
    begin
      @(posedge clk);
      valid_in <= 1;
      data_in  <= sample;
      @(posedge clk);
      valid_in <= 0;
      data_in  <= 0;
    end
  endtask

  // Moving average model
  int unsigned window[3:0];
  int unsigned sum;
  int unsigned expected_avg;
  int unsigned expected_delay[PIPELINE_LATENCY:0];
  int i;

  initial begin
    clk = 0; rst_n = 0;
    valid_in = 0; data_in = 0;
    sum = 0;
    expected_avg = 0;
    for (i = 0; i < 4; i++) window[i] = 0;
    for (i = 0; i <= PIPELINE_LATENCY; i++) expected_delay[i] = 0;

    // Reset
    repeat (3) @(posedge clk);
    rst_n = 1;
    @(posedge clk);

    // Apply 8 input samples
    send_sample(10);
    send_sample(20);
    send_sample(30);
    send_sample(40);
    send_sample(50);
    send_sample(60);
    send_sample(70);
    send_sample(80);

    // Wait for pipeline flush
    repeat (12) @(posedge clk);
    $finish;
  end

  // Model the expected average and apply pipeline delay
  always @(posedge clk) begin
    if (!rst_n) begin
      for (i = 0; i < 4; i++) window[i] = 0;
      for (i = 0; i <= PIPELINE_LATENCY; i++) expected_delay[i] = 0;
      sum = 0;
      expected_avg = 0;
    end
    else begin
      // Shift window
      if (valid_in) begin
        window[3] = window[2];
        window[2] = window[1];
        window[1] = window[0];
        window[0] = data_in;
      end

      sum = window[0] + window[1] + window[2] + window[3];
      expected_avg = sum / 4;

      // Shift the expected value through a delay line
      expected_delay[0] = expected_avg;
      for (i = 1; i <= PIPELINE_LATENCY; i++)
        expected_delay[i] = expected_delay[i-1];
    end
  end

  // Compare outputs
  always @(posedge clk) begin
    if (valid_out) begin
      $display("[%0t] data_out = %0d, expected = %0d ?", 
               $time, data_out, expected_delay[PIPELINE_LATENCY]);
    end
  end

endmodule
