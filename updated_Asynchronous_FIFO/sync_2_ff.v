`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.02.2025 11:59:07
// Design Name: 
// Module Name: sync_2_ff
// Project Name: 
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


module sync_2_ff(
input clk ,rst ,
input [3:0]sync_inp, // input to two flop syncroniser  
output reg [3:0]q2
    );
    reg[3:0]q1;
     always @(posedge clk or posedge rst) begin
           if (rst) begin
               q1 <= 4'b0000;
               q2 <= 4'b0000;
           end else begin
               q1 <= sync_inp;
               q2 <= q1;
           end
       end
endmodule
