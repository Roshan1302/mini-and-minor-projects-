module axi_lite_top (
  input          wr,
  input          clk,
  input          resetn,
  input  [2:0]  addr,
  input  [31:0]  din,
  input  [3:0]   strbin,
  output [31:0]  rd_out,
  output [1:0]   resp
);

  // Internal wires (AXI-Lite)
  wire         awvalid, awready;
  wire [2:0]  awaddr;
  wire         wvalid, wready;
  wire [31:0]  wdata;
  wire [3:0]   wstrb;
  wire         bvalid, bready;
  wire [1:0]   bresp;
  wire         arvalid, arready;
  wire [2:0]  araddr;
  wire         rvalid, rready;
  wire [31:0]  rdata;
  wire [1:0]   rresp;

  wire [31:0] led;
  wire [31:0] sw = 32'h0000000F;  // hardcoded switch input

  // Connect external signals
  assign rd_out = rdata;
  assign resp   = rresp;

  // Instantiate master controller (drives AXI-Lite based on inputs)
  axi_lite_master master_inst (
      .wr(wr),
      .clk    (clk),
      .resetn (resetn),
      .d_in(din),
      .strbin(strbin),
      .addrin(addr),
      .d_out(rd_out),
      
      .m_axi_awvalid (awvalid),
      .m_axi_awready (awready),
      .m_axi_awaddr  (awaddr),
  
      .m_axi_wvalid  (wvalid),
      .m_axi_wready  (wready),
      .m_axi_wdata   (wdata),
      .m_axi_wstrb   (wstrb),
  
      .m_axi_bvalid  (bvalid),
      .m_axi_bready  (bready),
      .m_axi_bresp   (bresp),
  
      .m_axi_arvalid (arvalid),
      .m_axi_arready (arready),
      .m_axi_araddr  (araddr),
  
      .m_axi_rvalid  (rvalid),
      .m_axi_rready  (rready),
      .m_axi_rdata   (rdata),
      .m_axi_rresp   (rresp)
    );

  // Instantiate slave
  axi_lite_slave slave_inst (
    .s_axi_aclk(clk),
    .s_axi_aresetn(resetn),
    .s_axi_awvalid(awvalid),
    .s_axi_awready(awready),
    .s_axi_awaddr(awaddr),
    .s_axi_wvalid(wvalid),
    .s_axi_wready(wready),
    .s_axi_wdata(wdata),
    .s_axi_wstrb(wstrb),
    .s_axi_bid(),
    .s_axi_bvalid(bvalid),
    .s_axi_bready(bready),
    .s_axi_bresp(bresp),
    .s_axi_arvalid(arvalid),
    .s_axi_arready(arready),
    .s_axi_araddr(araddr),
    .s_axi_rvalid(rvalid),
    .s_axi_rready(rready),
    .s_axi_rdata(rdata),
    .s_axi_rresp(rresp)
  );

endmodule
