module async_rst_synchronization(
    input  logic clk,
    input  logic async_rstn,     // async active low reset
    output logic sync_rstn       // synced active low reset
);

    logic [1:0] ff_rst_sync;

    always @(posedge clk or negedge async_rstn) begin
        if (!async_rstn) begin
            ff_rst_sync <= 2'b00;   // async assertion
        end
        else begin
            ff_rst_sync[0] <= 1'b1;        // first stage
            ff_rst_sync[1] <= ff_rst_sync[0]; // second stage
        end
    end

    assign sync_rstn = ff_rst_sync[1];  // <-- stable output

endmodule
