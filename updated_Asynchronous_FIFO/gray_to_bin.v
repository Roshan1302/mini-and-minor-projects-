`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.02.2025 11:58:40
// Design Name: 
// Module Name: gray_to_bin
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


module gray_to_bin(
input [3:0]gray,
output[3:0]bin 
    );
    genvar gvi;
        generate
            for (gvi = 0; gvi < 4; gvi = gvi + 1) begin
                assign bin[gvi] = ^(gray >> gvi);
                assign bin[gvi] = ^(gray >> gvi);
            end
        endgenerate
endmodule
