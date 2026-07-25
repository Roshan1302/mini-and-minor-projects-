

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.12.2025 11:11:05
// Design Name: 
// Module Name: axi_full
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

module axi4_pipelined(
    input clk, rstn, 
    input [1:0]usr_wr_rd_req,
    input [31:0] usr_wr_addr_in,
    input [7:0]  usr_burst_len,
    input [1:0]  usr_wr_burst,
    input [31:0] usr_data_in,
    input [31:0] usr_rd_addr_in,
    input [1:0]  usr_rd_burst,
    output [31:0] rd_data_out,
    output pc_asserted,
    output rd_data_valid,
    input aw_vld_in,
    input usr_data_vld_in,usr_wr_ready,
    input logic [2:0]usr_transaction_id,
    output logic[2:0]usr_trf_size
    );
    wire sync_rstn;
    // AXI signals
    wire [2:0] m_axi_awid;
    wire [31:0] m_axi_awaddr;
    wire [2:0] m_axi_awsize;
    wire [1:0] m_axi_awburst;
    wire [7:0] m_axi_awlen;
    wire [1:0] m_axi_awlock;
    wire [3:0] m_axi_awcache;
    wire [2:0] m_axi_awprot;
    wire [3:0] m_axi_awqos;
    wire [4:0] m_axi_awuser;
    wire m_axi_awvalid;
    wire m_axi_awready;
    wire [31:0] m_axi_wdata;
    wire m_axi_wlast;
    wire m_axi_wvalid;
    wire m_axi_wready;
    wire [3:0]m_axi_wstrb;
    wire [2:0] m_axi_bid;
    wire [1:0] m_axi_brd_resp;
    wire m_axi_bvalid;
    wire m_axi_bready;
    
    wire [31:0] m_axi_araddr;
    wire [7:0] m_axi_arlen;
    wire [2:0] m_axi_arsize;
    wire [1:0] m_axi_arburst;
    wire [1:0] m_axi_arlock;
    wire [3:0] m_axi_arcache;
    wire [2:0] m_axi_arprot;
    wire [3:0] m_axi_arqos;
    wire [4:0] m_axi_aruser;
    wire m_axi_arvalid;
    wire m_axi_arready;
    
    wire [31:0] m_axi_rdata;
    wire [1:0] m_axi_rrd_resp;
    wire m_axi_rlast;
    wire m_axi_rvalid;
    wire m_axi_rready;
    

 async_rst_sync rst_synchroniser(
        .clk(clk),
        .async_rstn(rstn),     // async active low reset
        .sync_rstn(sync_rstn)  // synced active low reset
    );
axi_4_master master_inst (
////////////////////////////////// AW CHANEEL ///////////////////////////////////
        .m_axi_aclk(clk),
        .m_axi_rstn(sync_rstn),
        .m_axi_awid(m_axi_awid),
        .m_axi_awaddr(m_axi_awaddr),
        .m_axi_awsize(m_axi_awsize),
        .m_axi_awburst(m_axi_awburst),
        .m_axi_awlen(m_axi_awlen),
        .m_axi_awlock(m_axi_awlock),
        .m_axi_awcache(m_axi_awcache),
        .m_axi_awprot(m_axi_awprot),
        .m_axi_awqos(m_axi_awqos),
        .m_axi_awuser(m_axi_awuser),
        .m_axi_awvalid(m_axi_awvalid),
        .m_axi_awready(m_axi_awready),
////////////////////////////////// W CHANEEL ///////////////////////////////////
        .m_axi_wdata(m_axi_wdata),
        .m_axi_wlast(m_axi_wlast),
        .m_axi_wvalid(m_axi_wvalid),
        .m_axi_wready(m_axi_wready),
        .m_axi_wstrb(m_axi_wstrb),
////////////////////////////////// WRESP CHANEEL ///////////////////////////////////
        .m_axi_bid(m_axi_bid),
        .m_axi_bvalid(m_axi_bvalid),
        .m_axi_bready(m_axi_bready),
////////////////////////////////// AR CHANEEL ///////////////////////////////////
        .m_axi_araddr(m_axi_araddr),
        .m_axi_arlen(m_axi_arlen),
        .m_axi_arsize(m_axi_arsize),
        .m_axi_arburst(m_axi_arburst),
        .m_axi_arlock(m_axi_arlock),
        .m_axi_arcache(m_axi_arcache),
        .m_axi_arprot(m_axi_arprot),
        .m_axi_arqos(m_axi_arqos),
        .m_axi_aruser(m_axi_aruser),
        .m_axi_arvalid(m_axi_arvalid),
        .m_axi_arready(m_axi_arready),
////////////////////////////////// R CHANEEL ///////////////////////////////////
        .m_axi_rdata(m_axi_rdata),
        .m_axi_rlast(m_axi_rlast),
        .m_axi_rvalid(m_axi_rvalid),
        .m_axi_rready(m_axi_rready),
////////////////////////////////// USR interface ///////////////////////////////////
        .usr_wr_rd_req(usr_wr_rd_req),
        .usr_wr_addr_in(usr_wr_addr_in),
        .usr_rd_addr_in(usr_rd_addr_in),
        .usr_data_in(usr_data_in),
        .usr_awlen(usr_burst_len),
        .usr_awsize(usr_trf_size),
        .usr_wr_burst(usr_wr_burst),
        .usr_rd_burst(usr_rd_burst),
        .usr_aw_id(usr_transaction_id),
        .rd_data_out(rd_data_out),
        .rd_data_valid(rd_data_valid),
        .usr_data_vld_in(usr_data_vld_in),
        .usr_wr_ready(usr_wr_ready),
        .usr_aw_vld_in(aw_vld_in)     // master ready for data
    );

axi_4_slave slave_inst (
        .s_axi_aclk(clk),
        .s_axi_aresetn(sync_rstn),
        
        .s_axi_awid(m_axi_awid),
        .s_axi_awvalid(m_axi_awvalid),
        .s_axi_awready(m_axi_awready),
        .s_axi_awaddr(m_axi_awaddr),
        .s_axi_awlen(m_axi_awlen),
        .s_axi_awsize(m_axi_awsize),
        .s_axi_awburst(m_axi_awburst),
        .s_axi_awlock(m_axi_awlock),
        .s_axi_awcache(m_axi_awcache),
        .s_axi_awprot(m_axi_awprot),
        .s_axi_awqos(m_axi_awqos),
//        .s_axi_awuser(m_axi_awuser),

        .s_axi_wvalid(m_axi_wvalid),
        .s_axi_wready(m_axi_wready),
        .s_axi_wdata(m_axi_wdata),
        .s_axi_wlast(m_axi_wlast),
        .s_axi_wstrb(m_axi_wstrb),

        .s_axi_bid(m_axi_bid),
        .s_axi_bvalid(m_axi_bvalid),
        .s_axi_bready(m_axi_bready),
        .s_axi_rresp(m_axi_brd_resp),

        .s_axi_arvalid(m_axi_arvalid),
        .s_axi_arready(m_axi_arready),
        .s_axi_araddr(m_axi_araddr),
        .s_axi_arlen(m_axi_arlen),
        .s_axi_arsize(m_axi_arsize),
        .s_axi_arburst(m_axi_arburst),
        .s_axi_arlock(m_axi_arlock),
        .s_axi_arcache(m_axi_arcache),
        .s_axi_arprot(m_axi_arprot),
        .s_axi_arqos(m_axi_arqos),
//        .s_axi_aruser(m_axi_aruser),

        .s_axi_rvalid(m_axi_rvalid),
        .s_axi_rready(m_axi_rready),
        .s_axi_rdata(m_axi_rdata),
        .s_axi_rlast(m_axi_rlast)
    );
endmodule