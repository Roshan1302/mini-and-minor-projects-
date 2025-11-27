`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.11.2025 16:58:09
// Design Name: 
// Module Name: t_keep_logic
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
//include axis_params_package::*;

module tkeep_gen #(parameter DATA_WIDTH     = 32,
                      PKT_LEN_WIDTH  = 8)(
    input  logic  tlast,       
    input  logic [15:0]  pkt_len,  // runtime packet length
    output logic [TKEEP_WIDTH-1:0]  tkeep        // tkeep output
);
    localparam int BUS_BYTES     = DATA_WIDTH / 8;
    localparam int TKEEP_WIDTH   = BUS_BYTES;
    localparam int MAX_PKT       = (1 << PKT_LEN_WIDTH);
    
    logic [TKEEP_WIDTH-1:0] tkeep_r;
    logic [$clog2(BUS_BYTES):0] last_keep;

    always_comb begin
        last_keep = pkt_len & (BUS_BYTES - 1);
        tkeep_r = {TKEEP_WIDTH{1'b1}};
        if (tlast) begin
            if (last_keep == 0)
                tkeep_r = {TKEEP_WIDTH{1'b1}};          // full beat
            else
                tkeep_r = (1 << last_keep) - 1;         // partial beat mask
        end
    end

    assign tkeep = tkeep_r;

endmodule

