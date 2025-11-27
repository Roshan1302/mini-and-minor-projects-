`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Roshan Ekre 
// 
// Create Date: 11.02.2025 12:08:07
// Design Name: Asynchronous FIFO 
// Module Name: updated_async_fifo_
// Project Name: FIFO 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module updated_async_fifo_ #(
    parameter FW = 8,  // FIFO data width
    parameter FD = 8 // FIFO depth
) (
    input w_clk,
    input r_clk,
    input w_rst,
    input r_rst,
    input wr,
    input rd,
    input [FW-1:0] wdata,
    output reg [FW-1:0] rdata,
    output full,
    output empty,
    output reg overflow,
    output reg underflow
);
    
    localparam ADDR_SIZE = $clog2(FD); // Address width
    
    // FIFO memory and pointers
    reg [ADDR_SIZE:0] wptr, rptr;
    reg [FW-1:0] mem[FD-1:0];

    // Gray-coded pointers
    wire [ADDR_SIZE:0] g_wptr, g_rptr; // register for gray pointer 
    wire  [ADDR_SIZE:0] g_wptr_q2;
    wire  [ADDR_SIZE:0] g_rptr_q2;

    // Binary pointers (converted from Gray)
    wire [ADDR_SIZE:0] bin_wptr, bin_rptr;

    // Write Operation
    always @(posedge w_clk or posedge w_rst) 
    begin
        if (w_rst)
            wptr <= 0;
        else if (wr && !full) begin
            mem[wptr[ADDR_SIZE-1:0]] <= wdata; // Write data to memory
            wptr <= wptr + 1'b1;
        end
    end

    // Read Operation
    always @(posedge r_clk or posedge r_rst) begin
        if (r_rst)
            rptr <= 0;
        else if (rd && !empty) begin
            rdata <= mem[rptr[ADDR_SIZE-1:0]]; // Read data from memory
            rptr <= rptr + 1'b1;
        end
    end
  //////////////////// Convert Binary Pointers to Gray Code/////////////////////////////////////
    bin_to_gray b_to_g_inst_wptr(.bin(wptr),.gray(g_wptr));   // for write pointer 
    bin_to_gray b_to_g_inst_rptr(.bin(rptr),.gray(g_rptr));   // for read pointer 

//////////////////////////// 2 flop synchroniser //////////////////////////////////////////////
    // Synchronizing Write Pointer to Read Domain
    sync_2_ff sync_2_ff_inst_wptr(.clk(r_clk),.rst(r_rst),.sync_inp(g_wptr),.q2(g_wptr_q2));
    // Synchronizing Read Pointer to Write Domain
    sync_2_ff sync_2_ff_inst_rptr(.clk(w_clk),.rst(w_rst),.sync_inp(g_rptr),.q2(g_rptr_q2));

 ///////////////// convert Gray to Binary (at the destination clock domain)///////////////////
    gray_to_bin g_to_b_inst_wptr(.gray(g_wptr_q2),.bin(bin_wptr)); // for wptr 
    gray_to_bin g_to_b_inst_rptr(.gray(g_rptr_q2),.bin(bin_rptr)); // for rptr 

 /////////////////////////////full and empty condition //////////////////////////////
    assign empty = (rptr == bin_wptr);
    assign full = ({~wptr[ADDR_SIZE], wptr[ADDR_SIZE-1:0]} == bin_rptr);
    
/////////////////////////////// Overflow Detection////////////////////////
    always @(posedge w_clk or posedge w_rst) begin
        if (w_rst)
            overflow <= 1'b0;
        else if (full && wr)
            overflow <= 1'b1;
        else
            overflow <= 1'b0;
    end

/////////////////// Underflow Detection  /////////////////////////////////
    always @(posedge r_clk or posedge r_rst) begin
        if (r_rst)
            underflow <= 1'b0;
        else if (empty && rd)
            underflow <= 1'b1;
        else
            underflow <= 1'b0;
    end
endmodule

