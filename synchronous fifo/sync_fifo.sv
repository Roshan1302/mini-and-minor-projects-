module sync_fifo #(parameter DEPTH=8, DATA_WIDTH=8) (
  input clk, rst,
  input w_en, r_en,
  input [DATA_WIDTH-1:0] data_in,
  output reg [DATA_WIDTH-1:0] data_out,
  output f_full, f_empty
);
  localparam ADDR_SIZE = $clog2(DEPTH); // Address width
    
    // FIFO memory and pointers
    reg [ADDR_SIZE:0]w_ptr, r_ptr;
  reg [DATA_WIDTH-1:0] fifo_mem[DEPTH];
  
  // Set Default values on reset.
  always@(posedge clk) begin
    if(!rst) begin
      w_ptr <= 0; r_ptr <= 0;
      data_out <= 0;
    end
  end
  
  // To write data to fifo_mem
  always@(posedge clk) begin
    if(w_en & !f_full)begin
      fifo_mem[w_ptr[ADDR_SIZE-1:0]] <= data_in;
      w_ptr <= w_ptr + 1;
    end
  end
  // To read data from fifo_mem
  always@(posedge clk) begin
    if(r_en & !f_empty) begin
      data_out <= fifo_mem[r_ptr[ADDR_SIZE-1:0]];
      r_ptr <= r_ptr + 1;
    end
  end
  
  assign f_full = ({~w_ptr[ADDR_SIZE], w_ptr[ADDR_SIZE-1:0]} == r_ptr);
  assign f_empty = (w_ptr == r_ptr);
endmodule
