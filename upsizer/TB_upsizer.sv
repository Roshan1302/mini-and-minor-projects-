module tb_upsizer;

  reg [255:0] inp;
  reg clk, rst;
  reg valid_in ;
  wire [1023:0] out;
  wire out_en; 

 
  upsizer DUT (
    .inp_data(inp),
    .clk(clk),
    .valid_in(valid_in),
    .rstn(rst),
    .data_out(out),
    .out_en(out_en) 
  );

 
  always #5 clk = ~clk;

  initial 
    begin
        $dumpfile("testbench.vcd"); 
        $dumpvars(0, tb_upsizer);
        clk =#0 0;
        rst =#0 0;
        valid_in =#0 0 ;
        repeat (2) @(posedge clk);
        
        rst =#0 1; 
        valid_in =#0 1;
        inp =#0 256'h12c5f72ddeb17a83ed31c355aa490a3a7c5b2ac2bc5beb825ce023ff680cbf8a;
        
        @(posedge clk);
        inp =#0 256'h222417d063682b8fde044e33db7293c525ebee0369ad0aede53d758e84bf415b;
        
        @(posedge clk);
        inp =#0 256'h600748abbaf306a04dc1c5194ac6d8f9a4d6071745b4520bcbefd135eaee003a;
        
        @(posedge clk);
        valid_in =#0 0;
        inp =#0 256'h61cf6597389a007a242de744986a78f7c71bec00eca283a169086c4473051e8c;
        
        repeat (5) @(posedge clk);;
        valid_in =#0 1;
        inp =#0 256'h80494876d989831cebe584ab296a6609083b76b814461a2f5e9e6dcb4dc4b5e4;
        
        @(posedge clk);
        inp =#0 256'hb613613949e53a2e2f4190fa4a014dda75d96167b810e94c98ab8040c68a1554;
        
        @(posedge clk);
        inp =#0 256'hc7e23d39138a682f914b8a0c8dcbbdb8f8a91032a5d657f2f070f718a2e45a15;
        @(posedge clk);
        inp =#0 256'h80494876d989831cebe584ab296a6609083b76b814461a2f5e9e6dcb4dc4b5e4;
        
        @(posedge clk);
        inp =#0 256'hb613613949e53a2e2f4190fa4a014dda75d96167b810e94c98ab8040c68a1554;
        
        @(posedge clk);
        inp =#0 256'hc7e23d39138a682f914b8a0c8dcbbdb8f8a91032a5d657f2f070f718a2e45a15;
        
        @(posedge clk);
        $finish;
      end
    endmodule