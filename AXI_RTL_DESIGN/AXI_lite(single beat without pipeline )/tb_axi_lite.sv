`timescale 1ns / 1ns

module tb_axi_lite;

  // DUT Inputs
  logic        clk;
  logic        resetn;
  logic        wr;
  logic [2:0] wr_addr;
  logic [31:0] wr_din;
  logic [3:0]  wr_strbin;

  // DUT Outputs
  wire [31:0] rd_out;
  wire [1:0]  resp;

  // Instantiate DUT
  axi_lite_top dut (
    .clk(clk),
    .resetn(resetn),
    .wr(wr),
    .addr(wr_addr),
    .din(wr_din),
    .strbin(wr_strbin),
    .rd_out(rd_out),
    .resp(resp)
  );

  // Clock Generation
  always #5 clk = #0  ~clk;  // 100MHz

  // Stimulus
  initial begin
    // Dump waveform
//    $dumpfile("axi_lite_top_1.vcd");
//    $dumpvars(0, tb_axi_lite_top_1);

    // Initialize inputs
    wr        = #0  1;
    clk       = #0  0;
    wr_addr   = #0  0;
    wr_din    = #0  32'hACEFABEB;;
    wr_strbin = #0  0;

    // Reset
    resetn = #0  0;
    repeat(2) @(posedge clk);
    resetn = #0  1;

    // --------------------------
    // Write to LED at addr 0x04
    // --------------------------
    @(posedge clk);
    wr        = #0  1;
    wr_addr   = #0  3'b111;
    wr_din    = #0  32'hCAFEBABE;
    wr_strbin = #0  4'b1111;
    repeat(2) @(posedge clk);
        wr        = #0  1;
        wr_addr   = #0  3'b001;
        wr_din    = #0  32'hFAFEBBE;
        wr_strbin = #0  4'b1011;
        
        @(posedge clk);
            wr        = #0  1;
            wr_addr   = #0  3'b010;
            wr_din    = #0  32'hCAFEBABF;
            wr_strbin = #0  4'b0111;
            
            @(posedge clk);
                wr        = #0  1;
                wr_addr   = #0  3'b011;
                wr_din    = #0  32'habbca443;
                wr_strbin = #0  4'b1011;
    // Wait some cycles for AXI transaction to complete
   repeat(4) @(posedge clk);
   wr = #0 0;
   wr_addr   = #0  3'b010;
   repeat(4) @(posedge clk);
   wr_addr   = #0  3'b011;
   repeat(5) @(posedge clk);
    $finish;
  end

endmodule
