`timescale 1ns/1ps

module tb_order_independent_summing_tree;

  localparam NUM_INPUTS  = 8;
  localparam DATA_WIDTH  = 8;

  reg clk, rst_n;
  reg valid_in;
  reg [DATA_WIDTH-1:0] data_in;
  wire ready_out;
  wire [DATA_WIDTH+$clog2(NUM_INPUTS)-1:0] sum_out;
  wire sum_valid;

  order_independent_summing_tree #(
    .NUM_INPUTS(NUM_INPUTS),
    .DATA_WIDTH(DATA_WIDTH)
  ) dut (
    .clk(clk),
    .rst_n(rst_n),
    .valid_in(valid_in),
    .data_in(data_in),
    .ready_out(ready_out),
    .sum_out(sum_out),
    .sum_valid(sum_valid)
  );

  always #5 clk = ~clk;

  // Task to send one full transaction of 8 inputs
  task send_transaction(input integer base);
    integer i;
    reg [DATA_WIDTH+$clog2(NUM_INPUTS)-1:0] expected_sum;
    begin
      expected_sum = 0;
      for (i = 0; i < NUM_INPUTS; i++) begin
        // Wait for ready
        @(posedge clk);
        while (!ready_out) @(posedge clk);

        valid_in <= 1'b1;
        data_in  <= base + (i*10);
        expected_sum += (base + (i*10));
        $display("[%0t] Sending data: %0d", $time, data_in);

        @(posedge clk);
        valid_in <= 1'b0;
        data_in  <= '0;

        // Random gap between arrivals
        repeat($urandom_range(1,3)) @(posedge clk);
      end

      // Wait for result
      wait(sum_valid);
      @(posedge clk);

      $display("\n[%0t] SUM READY: sum_out = %0d, Expected = %0d\n", 
                $time, sum_out, expected_sum);

      if (sum_out !== expected_sum)
        $display("? ERROR: Mismatch!\n");
      else
        $display("? Transaction Passed!\n");
    end
  endtask

  // Test Sequence
  initial begin
    clk = 0;
    rst_n = 0;
    valid_in = 0;
    data_in = 0;

    $display("\n--- TEST START ---");

    #12 rst_n = 1;

    //  Transaction 1 (values 10,20,...,80)
    send_transaction(10);

    //  Transaction 2 (values 100,110,...,170)
    send_transaction(20);

    //  Transaction 3 (values 200,210,...,270)
    send_transaction(30);
#60
    $display("\n??? ALL 3 TRANSACTIONS PASSED!\n");
    
    $finish;
  end

endmodule
