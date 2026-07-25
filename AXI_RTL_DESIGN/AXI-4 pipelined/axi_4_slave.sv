
 module axi_4_slave #(
    parameter DATA_WIDTH   = 32,
    parameter ADDR_WIDTH   = 32,
    parameter ID_WIDTH     = 3,
    parameter AWLEN_WIDTH    = 8,   // AXI4 burst length = 8 bits
    parameter AWSIZE_WIDTH   = 3,   // AWSIZE/ARSIZE = 3 bits
    parameter AWSTRB_WIDTH   = DATA_WIDTH/8,
    parameter AWBURST_WIDTH =2
)
(
    ////////////////// CLOCK & RESET //////////////////
    input  logic                    s_axi_aclk,
    input  logic                    s_axi_aresetn,

    ////////////////// WRITE ADDRESS CHANNEL //////////////////
    input  logic [ID_WIDTH-1:0]     s_axi_awid,
    input  logic                    s_axi_awvalid,
    output logic                    s_axi_awready,
    input  logic [ADDR_WIDTH-1:0]   s_axi_awaddr,
    input  logic [AWLEN_WIDTH-1:0]    s_axi_awlen,
    input  logic [AWSIZE_WIDTH-1:0]   s_axi_awsize,
    input  logic [AWBURST_WIDTH-1:0]  s_axi_awburst,
    input  logic                    s_axi_awlock,
    input  logic [3:0]              s_axi_awcache,
    input  logic [2:0]              s_axi_awprot,
    input  logic [3:0]              s_axi_awqos,

    ////////////////// WRITE DATA CHANNEL //////////////////
    input  logic                    s_axi_wvalid,
    output logic                    s_axi_wready,
    input  logic [DATA_WIDTH-1:0]   s_axi_wdata,
    input  logic                    s_axi_wlast,
    input [AWSTRB_WIDTH-1:0]      s_axi_wstrb,

    ////////////////// WRITE RESPONSE CHANNEL //////////////////
    output logic [ID_WIDTH-1:0]     s_axi_bid,
    output logic                    s_axi_bvalid,
    input  logic                    s_axi_bready,
    output logic [1:0]              s_axi_bresp,

    ////////////////// READ ADDRESS CHANNEL //////////////////
    input  logic [ID_WIDTH-1:0]     s_axi_arid,
    input  logic                    s_axi_arvalid,
    output logic                    s_axi_arready,
    input  logic [ADDR_WIDTH-1:0]   s_axi_araddr,
    input  logic [AWLEN_WIDTH-1:0]    s_axi_arlen,
    input  logic [AWSIZE_WIDTH-1:0]   s_axi_arsize,
    input  logic [1:0]              s_axi_arburst,
    input  logic                    s_axi_arlock,
    input  logic [3:0]              s_axi_arcache,
    input  logic [2:0]              s_axi_arprot,
    input  logic [3:0]              s_axi_arqos,

    ////////////////// READ DATA CHANNEL //////////////////
    output logic                    s_axi_rvalid,
    input  logic                    s_axi_rready,
    output logic [DATA_WIDTH-1:0]   s_axi_rdata,
    output logic                    s_axi_rlast,
    output logic [1:0]              s_axi_rresp
);
assign s_axi_wready  = 1'b1 ;
assign s_axi_awready = 1'b1 ;
assign s_axi_arready = 1'b1 ;

reg[7:0]slv_mem[31:0];
 wire [31:0]wr_wrap_base_addr;
 wire wr_upper_wrap_boundry ;
 reg[2:0] slv_wr_trf_cnt;
 
 integer a,i,wr_align_addr;
 logic [31:0] wr_next_updated_addr_reg;
 logic [31:0] wr_next_updated_addr;
 assign s_axi_awready = 1'b1;
  always @(posedge s_axi_aclk )
    begin 
      if(!s_axi_aresetn)
        begin 
          slv_wr_trf_cnt <= 'b0 ;
          s_axi_bvalid <= 'b0;
          for (i = 0; i < 16; i = i + 1)
            slv_mem[i] <= 0;
        end
      else 
        begin 
          wr_next_updated_addr<=wr_next_updated_addr_reg;
          if(s_axi_awvalid && s_axi_awready && s_axi_wvalid && s_axi_wready)
            begin 
              for(int j =0; j<=s_axi_awlen;j=j+1)
                begin
                  if(s_axi_wstrb[j])
                  slv_mem[wr_next_updated_addr+j] <= s_axi_wdata[j*8+7-:8];
                end 
              slv_wr_trf_cnt <= slv_wr_trf_cnt +1'b1 ;
              s_axi_bvalid <= 'b0;
              if(s_axi_wlast )
                begin 
                  s_axi_bvalid <= 'b1 ;
                  slv_wr_trf_cnt <= 'b0 ;
                end 
            end 
        end 
    end 
    
    slv_addr_calculation #(
        .DATA_WIDTH     (DATA_WIDTH),
        .ADDR_WIDTH     (ADDR_WIDTH),
        .ID_WIDTH       (ID_WIDTH),
        .AWLEN_WIDTH    (AWLEN_WIDTH),
        .AWSIZE_WIDTH   (AWSIZE_WIDTH),
        .AWSTRB_WIDTH   (AWSTRB_WIDTH),
        .AWBURST_WIDTH  (AWBURST_WIDTH)
    ) u_slv_addr_cal (
    
        ////////////////// CLOCK & RESET //////////////////
        .s_axi_aclk        (s_axi_aclk),
        .s_axi_aresetn     (s_axi_aresetn),
    
        ////////////////// HANDSHAKE SIGNALS //////////////////
        .s_axi_awvalid     (s_axi_awvalid),
        .s_axi_arvalid     (s_axi_arvalid),
        .s_axi_awready     (s_axi_awready),
        .s_axi_arready     (s_axi_arready),
        .s_axi_addr_in     (s_axi_awaddr),
        .nxt_addr_out      (wr_next_updated_addr_reg),
        .s_axi_wvalid      (s_axi_wvalid),
        .s_axi_rvalid      (s_axi_rvalid),
        .s_axi_wready      (s_axi_wready),
        .s_axi_rready      (s_axi_rready),
    
        ////////////////////////////////////////////////////////
        .s_axi_awlen       (s_axi_awlen),
        .s_axi_awsize      (s_axi_awsize),
        .s_axi_awid        (s_axi_awid),
        .s_axi_awburst     (s_axi_awburst),
        .slv_wr_trf_cnt    (slv_wr_trf_cnt)
    
    );
/////////////////////////////////////write logic ///////////////////////////////////////
                
  
/////////////////////////////// resp logic //////////////////////
//wire addr_decode_error,slave_error;
//assign addr_decode_err = ;

//// BRESP driven based on address decode / access result
//always @(*) 
//  begin
//    if (addr_decode_error)
//      s_axi_bresp = 2'b11;   // DECERR
//    else if (slave_error)
//      s_axi_bresp = 2'b10;   // SLVERR
//    else
//      s_axi_bresp = 2'b00;   // OKAY
//  end
/////////////////////////////// rd logic //////////////////////
endmodule
