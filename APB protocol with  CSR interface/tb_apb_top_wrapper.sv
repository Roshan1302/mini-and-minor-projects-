module tb_apb_top_wrapper #(parameter  
                             ADDR_WIDTH = 16, 
                             DATA_WIDTH = 32 );

    // Clock and Reset
    logic                     pclk;
    logic                     prstn;
    
    // Transfer interface
    logic                     trf_valid;
    logic [1:0]               trf_enc;
    logic [ADDR_WIDTH-1:0]    trf_addr;
    logic [DATA_WIDTH-1:0]    trf_wdata;

    logic [DATA_WIDTH-1:0]    trf_rdata;
    logic                     trf_rdata_valid;

    // Status and interrupt
    logic                     intr;
    logic                     tx_done_i;
    logic                     rx_done_i;
    logic                     arb_done_i;

    // Instantiate DUT
    apb_top_wrapper DUT (
        .pclk(pclk), 
        .prstn(prstn), 
        .trf_valid(trf_valid),
        .trf_enc(trf_enc),
        .trf_addr(trf_addr),
        .trf_wdata(trf_wdata),
        .trf_rdata(trf_rdata),
        .trf_rdata_valid(trf_rdata_valid),
        .intr(intr),
        .tx_done_i(tx_done_i),
        .rx_done_i(rx_done_i),
        .arb_done_i(arb_done_i)
    );

    // Clock generation
    always #5 pclk = ~pclk;

    // Initialization and stimulus
    initial begin
        pclk = 1'b0;
        prstn = 1'b0;
        trf_valid = 1'b0;
        trf_enc = 2'b11;
        trf_addr = 'b0;
        trf_wdata = 'b0;
        tx_done_i = 1'b1;
        rx_done_i = 1'b1;
        arb_done_i = 1'b1;

        #15 prstn = 1'b1;

        // ---------- Write transfers ----------
        for (int i = 0; i < 'h2C; i = i + 4) begin
            @(posedge pclk);
            trf_addr  = i;
            trf_valid = 1'b1;
            trf_enc   = 2'b01;        // Write
            trf_wdata = $random;

            @(posedge pclk);
            trf_valid = 1'b0;
        end

        // ---------- Read transfers ----------
        for (int i = 0; i < 'h2C; i = i + 4) begin
            @(posedge pclk);
            trf_addr  = i;
            trf_valid = 1'b1;
            trf_enc   = 2'b10;        // Read
            trf_wdata = $random;

            @(posedge pclk);
            trf_valid = 1'b0;
        end
    end

    // Dumping waveform
    initial begin
        $dumpfile("apb_top_wave.vcd");
        $dumpvars(0, tb_apb_top_wrapper);
        #1000 $finish();
    end

endmodule : tb_apb_top_wrapper
