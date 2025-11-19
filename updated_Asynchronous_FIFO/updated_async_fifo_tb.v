`timescale 1ns / 1ps

module updated_async_fifo_tb();
      
    reg w_clk;
    reg r_clk;
    reg r_rst, w_rst, wr, rd;
    reg [7:0] wdata;
    
    wire [7:0] rdata;
    wire full, empty;
    wire overflow, underflow;
    integer i;
    
    updated_async_fifo_ #(8, 8) DUT (
        .w_clk(w_clk),
        .r_clk(r_clk),
        .w_rst(w_rst),
        .r_rst(r_rst),
        .wr(wr),
        .rd(rd),
        .wdata(wdata),
        .rdata(rdata),
        .full(full),
        .empty(empty),
        .overflow(overflow),
        .underflow(underflow)
    );
    
    always #7 r_clk = ~r_clk;
    always #5 w_clk = ~w_clk;
    
    initial begin
        r_clk = 1;
        w_clk = 0;
        {wr, rd, w_rst, r_rst} = 4'b0011;
        #23;
        {wr, rd, w_rst, r_rst} = 4'b1000;
        
        for (i = 0; i < 8; i = i + 1) begin
            wdata = i;
            #10;
        end
        
        #14;
        {wr, rd, w_rst, r_rst} = 4'b0100;
        #17;
        {wr, rd, w_rst, r_rst} = 4'b0100;
        #150;
        $finish;
    end 
endmodule
