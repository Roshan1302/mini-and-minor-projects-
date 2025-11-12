module apb_top_wrapper #(parameter 

            ADDR_WIDTH = 16,
            DATA_WIDTH = 32 )

(
    input logic prstn, 
    input logic pclk,
    
    input  logic [7:0] trf_addr,
    input  logic [7:0] trf_wdata, 
    input  logic       trf_valid, 
    output logic       trf_rdata_valid,	
    output logic [7:0]trf_rdata,
    input  logic [1:0]trf_enc,
     
    output  logic   intr ,           //Interrupt Pin
    input   logic   tx_done_i,      //For Status_reg
    input   logic   rx_done_i,
    input   logic   arb_done_i
    
    );
    
    reg                    psel;
    reg                    penable;
    reg                    pwrite;
    reg[ADDR_WIDTH-1:0]    paddr;
    reg[DATA_WIDTH-1:0]    pwdata;

    bit[DATA_WIDTH-1:0]    prdata;
    reg                    pready;
    reg                    pslverr;

    apb_master_for_csr master(
    .pclk(pclk), 
    .prstn(prstn) , 
    .trf_valid(trf_valid), 
    .trf_enc(trf_enc), 
    .trf_addr(trf_addr),
    .trf_wdata (trf_wdata), 
    .trf_rdata(trf_rdata), 
    .trf_rdata_valid(trf_rdata_valid), 
    .psel(psel), 
    .penable(penable), 
    .pwrite(pwrite), 
    .paddr(paddr),
    .pwdata(pwdata), 
    .prdata(prdata), 
    .pready(pready) , 
    .pslverr(pslverr));



    CSR slave(
    .pclk(pclk), 
    .preset_n(preset_n), 
    .psel(psel), 
    .penable(penable), 
    .pwrite(pwrite), 
    .paddr(paddr), 
    .pwdata(pwdata), 
    .prdata(prdata), 
    .pready(pready), 
    .pslverr(pslverr), 
    .intr(intr), 
    .tx_done_i(tx_done_i),
    .rx_done_i (rx_done_i), 
    .arb_done_i(arb_done_i) );
    

endmodule 