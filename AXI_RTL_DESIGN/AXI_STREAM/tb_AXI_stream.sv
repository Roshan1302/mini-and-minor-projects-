//`timescale 1ns / 1ps

module tb_AXI_stream;

  // Inputs
  reg m_clk;
  reg m_rst;
  reg m_ready;
  reg m_vld_in;
  reg [7:0] m_din;

  // Outputs
  wire m_vld_out;
  wire m_last;
  wire [7:0] m_dout;

  // Instantiate the DUT
  AXI_stream dut (
    .m_clk(m_clk),
    .m_rst(m_rst),
    .m_ready(m_ready),
    .m_vld_in(m_vld_in),
    .m_din(m_din),
    .m_vld_out(m_vld_out),
    .m_last(m_last),
    .m_dout(m_dout)
  );

  // Clock Generation
  initial begin
    m_clk=#0 0;
    forever #5 m_clk = ~m_clk; // 100MHz clock
  end

  // Stimulus
  initial begin
    // Default state
    m_rst =#0 1;
    m_ready =#0 0;
    m_vld_in=#0 0;
    m_din=#0 8'd0;
    // Apply Reset
    #12;
    m_rst=#0 0;

    repeat (2) @(posedge m_clk);
//    TS_1
    @(posedge m_clk);
    m_vld_in=#0 1;
    m_ready=#0 1;
    m_din=#0 8'hD0; 
    @(posedge m_clk);
    m_din=#0 8'hD1; 
    @(posedge m_clk);
    m_din=#0 8'hD2;
    @(posedge m_clk);
    m_din=#0 8'hD3; 
    
//    test case_2
    @(posedge m_clk); 
    m_din=#0 8'hD0; 
    @(posedge m_clk);
    m_din=#0 8'hD1; 
    @(posedge m_clk);
     m_ready=#0 0;
     m_din=#0 8'hD2;
     @(posedge m_clk);
     m_ready=#0 1;
//    @(posedge m_clk);
    m_din=#0 8'hD3;
    
//    testcase_3    
    @(posedge m_clk); 
    m_din=#0 8'hD0; 
    @(posedge m_clk);
    m_din=#0 8'hD1; 
    @(posedge m_clk);
    m_din=#0 8'hD2;
    @(posedge m_clk);
    m_ready=#0 0;
     @(posedge m_clk);
     m_ready=#0 1;
    m_din=#0 8'hD3;
    #40
    
    $finish;
  end
  initial begin
    $monitor("Time=%0t | rst=%b | valid_in=%b | ready=%b | din=%h || valid_out=%b | last=%b | dout=%h",
             $time, m_rst, m_vld_in, m_ready, m_din, m_vld_out, m_last, m_dout);
  end

endmodule
//module tb_AXI_stream;

//  // Inputs
//  reg m_clk;
//  reg m_rst;
//  reg m_ready;
//  reg m_vld_in;
//  reg [7:0] m_din;

//  // Outputs
//  wire m_vld_out;
//  wire m_last;
//  wire [7:0] m_dout;

//  // Instantiate the DUT
//  AXI_stream dut (
//    .m_clk(m_clk),
//    .m_rst(m_rst),
//    .m_ready(m_ready),
//    .m_vld_in(m_vld_in),
//    .m_din(m_din),
//    .m_vld_out(m_vld_out),
//    .m_last(m_last),
//    .m_dout(m_dout)
//  );

//  // Clock Generation
//  initial begin
//    m_clk = 0;
//    forever #5 m_clk = ~m_clk; // 100MHz clock
//  end

//  // Stimulus
//  initial begin
//    // Default state
//    m_rst = 1;
//    m_ready = 0;
//    m_vld_in = 0;
//    m_din = 8'd0;
    
//    // Apply Reset
//    #12;
//    m_rst = 0;

//    repeat (2) @(posedge m_clk);
    
//    // Test Case 1
//    @(posedge m_clk);
//    m_vld_in = 1;
//    m_ready = 1;
//    m_din = 8'hD0; 
//    @(posedge m_clk);
//    m_din = 8'hD1; 
//    @(posedge m_clk);
//    m_din = 8'hD2;
//    @(posedge m_clk);
//    m_din = 8'hD3; 
    
//    // Test Case 2
//    @(posedge m_clk); 
//    m_din = 8'hD0; 
//    @(posedge m_clk);
//    m_din = 8'hD1; 
//    @(posedge m_clk);
//    m_ready = 0;
//    m_din = 8'hD2;
//    @(posedge m_clk);
//    m_ready = 1;
//    m_din = 8'hD3;
    
//    // Test Case 3    
//    @(posedge m_clk); 
//    m_din = 8'hD0; 
//    @(posedge m_clk);
//    m_din = 8'hD1; 
//    @(posedge m_clk);
//    m_din = 8'hD2;
//    @(posedge m_clk);
//    m_ready = 0;
//    @(posedge m_clk);
//    m_ready = 1;
//    m_din = 8'hD3;

//    #40;
//    $finish;
//  end

//  initial begin
//    $monitor("Time=%0t | rst=%b | valid_in=%b | ready=%b | din=%h || valid_out=%b | last=%b | dout=%h",
//             $time, m_rst, m_vld_in, m_ready, m_din, m_vld_out, m_last, m_dout);
//  end

//endmodule
