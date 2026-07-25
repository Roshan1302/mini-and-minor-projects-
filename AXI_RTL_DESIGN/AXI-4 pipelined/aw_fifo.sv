`timescale 1ns / 1ps
module aw_fifo #(parameter DEPTH=8, DATA_WIDTH=48) (
  input clk, rst,
  input w_en, r_en,
  input [DATA_WIDTH-1:0] data_in,
  output [DATA_WIDTH-1:0] data_out,      // wire, not reg
  output f_full, f_empty
);
  localparam ADDR_SIZE = $clog2(DEPTH);

  reg [ADDR_SIZE:0] w_ptr, r_ptr;
  reg [DATA_WIDTH-1:0] fifo_mem[DEPTH];

  // Reset + write pointer
  always @(posedge clk) begin
    if (!rst) begin
      w_ptr <= 0;
      r_ptr <= 0;
    end
  end

  // Write - registered (memory must be clocked)
  always @(posedge clk) begin
    if (w_en && !f_full) begin
      fifo_mem[w_ptr[ADDR_SIZE-1:0]] <= data_in;
      w_ptr <= w_ptr + 1;
    end
  end

  // Read pointer advance - still clocked
  always @(posedge clk) begin
    if (r_en && !f_empty) begin
      r_ptr <= r_ptr + 1;
    end
  end

  assign data_out =(r_en && !f_empty)? fifo_mem[r_ptr[ADDR_SIZE-1:0]]:'b0;

  assign f_full  = ({~w_ptr[ADDR_SIZE], w_ptr[ADDR_SIZE-1:0]} == r_ptr);
  assign f_empty = (w_ptr == r_ptr);

endmodule