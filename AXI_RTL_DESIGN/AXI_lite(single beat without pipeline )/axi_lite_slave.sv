`timescale 1ns / 1ps

module axi_lite_slave ( 
  input  wire         s_axi_aclk,
  input  wire         s_axi_aresetn,

  // Write Address Channel
  input  wire         s_axi_awvalid,
  output reg          s_axi_awready,
  input  wire [2:0]  s_axi_awaddr,

  // Write Data Channel
  input  wire         s_axi_wvalid,
  output reg          s_axi_wready,
  input  wire [31:0]  s_axi_wdata,
  input  wire [3:0]   s_axi_wstrb,

  // Write Response Channel
  output reg [2:0]    s_axi_bid,
  output reg          s_axi_bvalid,
  input  wire         s_axi_bready,
  output reg [1:0]    s_axi_bresp,

  // Read Address Channel
  input  wire         s_axi_arvalid,
  output           s_axi_arready,
  input  wire [2:0]  s_axi_araddr,

  // Read Data Channel
  output reg          s_axi_rvalid,
  input           s_axi_rready,
  output  [31:0]   s_axi_rdata,
  output  [1:0]    s_axi_rresp

 
);
reg [31:0]mem[7:0] ; // 32x8 memory 
wire trf_wvalid;  // trf valid 
reg reg_awready,reg_wready,reg_bvalid ;
reg [1:0] reg_bresp ;
reg wdata_ready ,awaddr_ready ; 
wire write_handshake;
////////////write operation //////////////
always @(posedge s_axi_aclk )
  begin 
    if(~s_axi_aresetn )
    begin 
      for (int i = 0; i < 8; i = i + 1)
        mem[i] <= 32'h00000000;
      reg_wready <= 'b0;
      reg_awready <= 'b0;
      reg_bvalid <= 'b0 ;
    end   
    else 
      begin 
        if (s_axi_awready && s_axi_awvalid)
          begin 
            reg_bvalid <= 1'b1 ;
            reg_bresp <= 2'b11 ;
            reg_awready<= 1'b0;
            reg_wready <= 1'b0;
          end   
         else if(trf_wvalid )
            begin 
              //reg_bvalid <= 1'b0 ;
              reg_awready <= 1'b1 ;
              reg_wready<= 1'b1;
            end     
          else  
              reg_bvalid <= 1'b0 ;
          end 
          
      end    
  assign s_axi_awready = reg_awready;
  assign s_axi_wready = reg_wready;
  assign s_axi_bvalid = reg_bvalid;
  assign s_axi_bresp = s_axi_bvalid ? 2'b11: 2'b00;
  assign trf_wvalid = s_axi_awvalid && s_axi_wvalid  ;

////////////////////read operation //////////////
////////////////////read operation //////////////
////wire trf_rvalid =   ;  // trf valid 
reg reg_arready;
reg [1:0]reg_rvalid ;
reg [1:0] reg_rresp ;
always @(posedge s_axi_aclk )
  begin 
    if(~s_axi_aresetn )
    begin 
//      s_axi_rdata <= 'b0;
      reg_arready <= 'b0;
      reg_rvalid <= 'b0 ;
    end   
    else 
      begin 
        if (s_axi_arready && s_axi_arvalid)
          begin 
            reg_rvalid[1] <= 1'b1 ;
            reg_bresp <= 2'b11 ;
            reg_arready<= 1'b0;
          end   
         else if(s_axi_arvalid )
            begin 
              reg_arready <= 1'b1 ;
            end     
          else  
            begin 
              reg_rvalid <= 'b0 ;
//              s_axi_rdata <='b0 ;
            end  
          end 
          
      end     
      always @(posedge s_axi_aclk)reg_rvalid[0] <= reg_rvalid[1];
  assign s_axi_rdata =(s_axi_rvalid)? mem[s_axi_araddr]: 'b0 ;    
  assign s_axi_arready = reg_arready;
  assign s_axi_rvalid = reg_rvalid[0];
  assign s_axi_rresp = s_axi_rvalid ? 2'b11: 2'b00;

//----------------------------slave mem and strobe logic ---------------------------------------
  reg [31:0] new_word;
  reg [31:0] old_word; 
 assign wdata_ready = s_axi_awready & s_axi_awvalid ;
 assign awaddr_ready =s_axi_wready & s_axi_wvalid;
 assign write_handshake = wdata_ready & awaddr_ready ;

logic [31:0] byte_mask;
 
 always_comb begin
     byte_mask = 32'h0;
     for (int i = 0; i < 4; i++) begin
         if (s_axi_wstrb[i])
             byte_mask[(8*i) +: 8] = 8'hFF;
         else
             byte_mask[(8*i) +: 8] = 8'h00;
     end
 end
  always @(posedge s_axi_aclk) 
    begin
      if (write_handshake) 
        mem[s_axi_awaddr] <= (mem[s_axi_awaddr] & ~byte_mask) | (s_axi_wdata & byte_mask);
    end

      endmodule 
