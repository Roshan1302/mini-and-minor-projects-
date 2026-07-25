`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.12.2025 11:12:12
// Design Name: 
// Module Name: axi_full_master
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
module axi_4_master#(parameter    DATA_WIDTH=32 ,
                                  ADDR_WIDTH= 32,
                                  AWLEN_WIDTH=8,
                                  ARLEN_WIDTH=8,
                                  AWSIZE_WIDTH = 3,
                                  ID_WIDTH =3,
                                  AWBURST_WIDTH = 2,
                                  WSTRB_WIDTH   = DATA_WIDTH/8)
(    ////////////////input to top module ///////////////////////////
input  logic        m_axi_aclk,
input  logic        m_axi_rstn,
input  logic [1:0]  usr_wr_rd_req,      // start read=2'b10 / write=2'b01 transaction
input  logic [ADDR_WIDTH-1:0]     usr_rd_addr_in,
input  logic [ADDR_WIDTH-1:0]     usr_wr_addr_in,           // base address
input logic  [DATA_WIDTH-1:0]     usr_data_in,
input  logic [AWLEN_WIDTH-1:0]    usr_awlen,usr_arlen,           // burst length
input  logic [AWSIZE_WIDTH-1:0]   usr_awsize, usr_arsize,     // bytes per beat
input  logic [1:0]                usr_wr_burst,
input  logic [1:0]                usr_rd_burst,         // burst mode 
input  logic [ID_WIDTH-1:0]       usr_aw_id,usr_ar_id,

output logic [31:0] rd_data_out,
output logic        rd_data_valid,       // data valid
input  logic        m_ready,       // user ready

input  logic        usr_data_vld_in,
input  logic        usr_aw_vld_in, usr_ar_vld_in,    // addr valid
output logic        usr_wr_ready,       // master ready for data

////////////////// write addr channel //////////////////////
output logic [ID_WIDTH-1:0]  m_axi_awid,
output logic [31:0] m_axi_awaddr,
output logic [2:0]  m_axi_awsize,
output logic [AWBURST_WIDTH-1:0]  m_axi_awburst,
output logic [AWLEN_WIDTH-1:0]  m_axi_awlen,
output logic [1:0]  m_axi_awlock,
output logic [3:0]  m_axi_awcache,
output logic [2:0]  m_axi_awprot,
output logic [3:0]  m_axi_awqos,
output logic [4:0]  m_axi_awuser,
output logic        m_axi_awvalid,
input  logic        m_axi_awready,

//////////////// Write data channel /////////////////////////
output logic [31:0] m_axi_wdata,
output logic        m_axi_wlast,
output logic        m_axi_wvalid,
input  logic        m_axi_wready,
output logic [WSTRB_WIDTH-1:0]m_axi_wstrb,

//////////////// Write response channel /////////////////////
input  logic        m_axi_bid,
input  logic        m_axi_bresp,
input  logic        m_axi_bvalid,
output logic        m_axi_bready,

//////////////// Read address channel ///////////////////////
output logic [31:0] m_axi_araddr,
output logic [7:0]  m_axi_arlen,
output logic [2:0]  m_axi_arsize,
output logic [1:0]  m_axi_arburst,
output logic [ID_WIDTH-1:0]m_axi_arid,
output logic [1:0]  m_axi_arlock,
output logic [3:0]  m_axi_arcache,
output logic [2:0]  m_axi_arprot,
output logic [3:0]  m_axi_arqos,
output logic [4:0]  m_axi_aruser,
output logic        m_axi_arvalid,
input  logic        m_axi_arready,


//////////////// Read data channel /////////////////////////
input  logic [31:0] m_axi_rdata,
input  logic [1:0]  m_axi_rresp,
input  logic        m_axi_rlast,
input  logic        m_axi_rvalid,
output logic        m_axi_rready,

input  logic [23:0] wr_addr,
input  logic [7:0]  wr_burst_len,
input  logic [1:0]  wr_burst_type,
input  logic [31:0] wr_din,
input  logic [3:0]  wr_strbin,

input  logic [23:0] rd_addr,
input  logic [7:0]  rd_burst_len,
input  logic [1:0]  rd_burst_type,
output logic [31:0] rout
);
localparam FIX=2'b00,
           INCR =2'b01,
           WRAP =2'b10;
 ////////////////////////////////////////trf_counter /////////////////////////////////////
reg start ;
assign m_axi_rready = 1'b1 ;
reg [2:0] m_trf_wr_cntr ;
wire  aw_fifo_full,aw_fifo_empty;
wire  aw_fifo_w_en;
wire aw_fifo_r_en;
reg [AWLEN_WIDTH-1:0] active_awlen;
logic [ID_WIDTH + ADDR_WIDTH + AWLEN_WIDTH + AWSIZE_WIDTH + AWBURST_WIDTH - 1 : 0 ] fifo_aw_in,fifo_aw_out;
logic wr_burst_active;
assign m_axi_awvalid = usr_aw_vld_in & start & (usr_wr_rd_req== 2'b01);
assign aw_fifo_w_en = (usr_wr_rd_req== 2'b01) & start & (~aw_fifo_full) & usr_aw_vld_in;
assign m_axi_wlast = (( (m_trf_wr_cntr == m_axi_awlen) & start))|(aw_fifo_r_en & (fifo_aw_out[7:0]=='b0 )) ;
assign fifo_aw_in = {usr_aw_id, usr_wr_addr_in, usr_awsize, usr_wr_burst, usr_awlen};               
assign m_axi_bready =  'b1 ;
assign aw_fifo_r_en =(~aw_fifo_empty)& start & (m_trf_wr_cntr==2'b00) & m_axi_wvalid;   
assign m_axi_wvalid = usr_data_vld_in & start;
wstrb_logic strobe_logic_inst(
        .clk(m_axi_aclk),
        .rst(m_axi_rstn),
        .awvld(m_axi_awvalid & wr_burst_active),
        .awsize(m_axi_awsize),
        .addr_in(m_axi_awaddr),
        .wstrb(m_axi_wstrb),
        .awready(m_axi_awready));  
        
 aw_fifo aw_fifo_inst( 
        .clk(m_axi_aclk), 
        .rst(m_axi_rstn),
        .w_en(aw_fifo_w_en &&(|m_trf_wr_cntr)), 
        .r_en(aw_fifo_r_en),
        .data_in(fifo_aw_in),
        .data_out(fifo_aw_out),
        .f_full(aw_fifo_full), 
        .f_empty(aw_fifo_empty));
        always @(posedge m_axi_aclk) begin
            if (~m_axi_rstn)
                wr_burst_active <= 1'b0;
            else if (m_axi_wvalid )              // starting a new burst
               wr_burst_active <= 1'b1;
            else 
                wr_burst_active <= 1'b0;
        end
   always @(posedge m_axi_aclk)
     begin 
       if(~m_axi_rstn)
         begin 
           m_trf_wr_cntr <=  'b0 ;
           start <= 'b0;
           m_axi_wdata<='b0;
         end
       else 
         begin 
           start <= 1'b1;
           if ((usr_wr_rd_req == 2'b01)&& m_axi_wvalid && start && m_axi_wready) 
             begin
               m_axi_wdata <= usr_data_in;
               m_trf_wr_cntr <= m_trf_wr_cntr + 1'b1;
               if (m_axi_wlast) 
                 begin
                   m_trf_wr_cntr <= 'b0;
                 end
              end 
            else if (~m_axi_wready) 
              begin
                m_axi_wdata <= m_axi_wdata; // optional (can remove)
              end 
          end 
       end   
       always @(posedge m_axi_aclk)
          begin 
            if(~m_axi_rstn)
              {m_axi_awid, m_axi_awaddr, m_axi_awsize, m_axi_awburst, active_awlen} <= 'b0;
            else if(m_axi_awvalid && (aw_fifo_w_en) && aw_fifo_empty && m_axi_awready)
              {m_axi_awid, m_axi_awaddr, m_axi_awsize, m_axi_awburst, active_awlen} <= {usr_aw_id,usr_wr_addr_in,usr_awsize,usr_wr_burst,usr_awlen};
            else if( aw_fifo_r_en && m_axi_awready )
              {m_axi_awid, m_axi_awaddr, m_axi_awsize, m_axi_awburst, active_awlen} <= fifo_aw_out;
          end 
assign m_ready = ~aw_fifo_full;   

always @*
  begin
    m_axi_awlen = active_awlen ;
    if(( aw_fifo_r_en && m_axi_awready ))
      m_axi_awlen = fifo_aw_out[AWLEN_WIDTH-1:0];
    else if ((m_axi_awvalid && (aw_fifo_w_en) && aw_fifo_empty && m_axi_awready))
      m_axi_awlen = usr_awlen;
  end   
///////////////////////////////////// addr read channel //////////////////////
reg [2:0] m_trf_rd_cntr ;
wire  ar_fifo_full,ar_fifo_empty;
wire  ar_fifo_r_en;
wire ar_fifo_w_en;
reg [AWLEN_WIDTH-1:0] active_arlen;
logic [ID_WIDTH + ADDR_WIDTH + AWLEN_WIDTH + AWSIZE_WIDTH + AWBURST_WIDTH - 1 : 0 ] fifo_ar_in,fifo_ar_out;
logic rd_burst_active;
assign m_axi_arvalid = usr_ar_vld_in & start & (usr_wr_rd_req== 2'b10);
assign ar_fifo_r_en = (usr_wr_rd_req== 2'b01) & start & (~ar_fifo_full) & usr_ar_vld_in;
assign m_axi_rlast = ((rd_burst_active & (m_trf_wr_cntr == m_axi_awlen) & start))|(ar_fifo_w_en & (fifo_ar_in[7:0]=='b0 )) ;
assign fifo_ar_in = {usr_ar_id, usr_rd_addr_in, usr_arsize, usr_rd_burst, usr_arlen};               
//assign m_axi_bready =  'b1 ;
assign ar_fifo_w_en =(~ar_fifo_empty)& start & (m_trf_wr_cntr==2'b00) & m_axi_rvalid;   
assign m_axi_rvalid = usr_data_vld_in & start;
 aw_fifo ar_fifo_inst( 
        .clk(m_axi_aclk), 
        .rst(m_axi_rstn),
        .w_en(ar_fifo_r_en &&(|m_trf_wr_cntr)), 
        .r_en(ar_fifo_w_en),
        .data_in(fifo_ar_in),
        .data_out(fifo_ar_in),
        .f_full(ar_fifo_full), 
        .f_empty(ar_fifo_empty));
        always @(posedge m_axi_aclk) begin
            if (~m_axi_rstn)
                rd_burst_active <= 1'b0;
            else if (m_axi_rvalid )              // starting a new burst
               rd_burst_active <= 1'b1;
            else 
                rd_burst_active <= 1'b0;
        end
   always @(posedge m_axi_aclk)
     begin 
       if(~m_axi_rstn)
         begin 
           m_trf_wr_cntr <=  'b0 ;
           start <= 'b0;
         end
       else 
         begin 
           start <= 1'b1;
           if ((usr_wr_rd_req == 2'b10)&& m_axi_rvalid && m_axi_rready) 
             begin
               m_trf_wr_cntr <= m_trf_wr_cntr + 1'b1;
               if (m_axi_rlast) 
                 begin
                   m_trf_wr_cntr <= 'b0;
                 end
              end 
          end 
       end   
       always @(posedge m_axi_aclk)
          begin 
            if(~m_axi_rstn)
              {m_axi_arid, m_axi_araddr, m_axi_arsize, m_axi_arburst, active_arlen} <= 'b0;
            else if(m_axi_arvalid && (ar_fifo_r_en) && ar_fifo_empty && m_axi_arready)
              {m_axi_arid, m_axi_araddr, m_axi_arsize, m_axi_arburst, active_arlen} <= {usr_ar_id,usr_rd_addr_in,usr_arsize,usr_rd_burst,usr_arlen};
            else if( ar_fifo_w_en && m_axi_arready )
              {m_axi_arid, m_axi_araddr, m_axi_arsize, m_axi_arburst, active_arlen} <= fifo_ar_in;
          end 
assign m_ready = ~ar_fifo_full;   

always @*
  begin
    m_axi_arlen = active_arlen ;
    if(( ar_fifo_w_en && m_axi_arready ))
      m_axi_arlen = fifo_ar_in[ARLEN_WIDTH-1:0];
    else if ((m_axi_arvalid && (ar_fifo_r_en) && ar_fifo_empty && m_axi_arready))
      m_axi_arlen = usr_arlen;
  end 
endmodule
      