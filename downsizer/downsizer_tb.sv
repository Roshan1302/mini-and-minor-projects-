module tb_downsizer;

   reg [1023:0] inp;
   reg clk, rst, valid_in;
   wire [255:0] out;
   wire out_en; 
   wire ready ;

   downsizer DUT (
     .inp_data(inp),
     .clk(clk),
     .ready(ready),
     .rstn(rst),
     .valid_in(valid_in),
     .data_out(out),
     .out_en(out_en) 
   );

   always #5 clk = ~clk;

   initial begin
     $dumpfile("testbench.vcd"); 
     $dumpvars(0, tb_downsizer);
     clk =#0 0;
     rst =#0 0;
     valid_in =#0 0;

     repeat (2) @(posedge clk);
     rst =#0 1; 
     valid_in =#0 1'b1;
     inp =#0  1024'ha8bcc5167e6450a4332ab2e27a2e87f96f74a4eb5602e3ed6b9b26b6d80e49ca55bc91380c52c5b367148584825eff12def5b395a610b7662efcc0c8014bce5a20dba2786e36a5d18c14a15918a16668873ab8b75296ee64e2475bade58e56ecb936a5d18c14a15918a16668873ab84f0e410513ad815997c4310260abcc516;
     
     @(posedge clk);
     inp =#0 1024'h732465e92a2dc67b6604ad5f0e41630bdc8a953a8d6bb76f13fa0fd181294527da7e631df57c3dee10d2f447f483fa9d1dba8ff21753185e199b5a026b8745d925e0c738952ef40d852e1bca5ba1b04f0fdb896a8f1751070f336204f0e410513ad815997c4310260a846ac32791e4332ab2e27a2e87f96f74a846ac32791ea;
     
     valid_in =#0 1'b0;
     repeat (4) @(posedge clk);
     valid_in =#0 1'b1;
     inp =#0 1024'h82befde001154fa0317b2d085ad75fe154c7c6b532afa17298eef02bb29a9322c0a790e36c2bfba906d30c1c0504b2a4526abae2124c656f75e774d0f0e474cf6c9b4318d0b5df4d6323dbf56a1fe4c97b8e3ff263120114b341db3413723fb894ce65ceffbe72ae4fb064c8f651fd8f79517f6b06a03ca3fbabb7a64d4b3a12;
     
     @(posedge clk);
     inp =#0 1024'h5edb2c09d710e56145329a1c276c44e8fc59229a3dd9c3b5d9abd9b8524b077c123fb145afbabc69294399eeddfd977a03c1854e5fe83f76f0747023427e55b4a893fbc00738d22cf8d9e8e4ee779ce6fbfd39b3ffba3ea38df6ec2ddfa97d323dc579f4402eb5d22742f412c2a8b736137a2f74206afdf643d245a20c995045;

     #10 
     inp =#0 1024'haabb65e92a2dc67b6604ad5f0e41630bdc8a953a8d6bb76f13fa0fd181294527da7e631df57c3dee10d2f447f483fa9d1dba8ff21753185e199b5a026b8745d925e0c738952ef40d852e1bca5ba1b04f0fdb896a8f17510700b7662efcc0c8014bce5a20dba2786eb75296ee64e2420dba2786eb75296ee64e246eb75296ee6a;

     #10;
     inp =#0 1024'hbbcc2a2dc67b6604ad5f0e41630bdc8a953a8d6bb76f13fa0fd181294527da7e631df57c3dee10d2f447f483fa9d1dba8ff21753185e199b5a026b8745d925e0c738952ef40d852e1bca5ba1b04f0fdb896a8f1751070f336204f0e410513ad815997c4310260abcc5167e6450a4332ab2e27a2e87f96f74a846ac32791eabab;

     #10;
     inp =#0 1024'h732465e92a2dc67b6604ad5f0e41630bdc8a953a8d6bb76f13fa0fd181294527da7e631df57c3dee10d2f447f483fa9d1dba8ff21753185e199b5a026b8745d925e0c738952ef40d852e1bca5ba1b04f0fdb896a8f1751070f336204f0e410513ad815997c4310260a846ac32791e4332ab2e27a2e87f96f74a846ac32791eab;

     #90
     $finish;
   end

   always @*
    begin
     if (out_en)
       $display("Time: %0t, Output: %h", $time, out);
   end

endmodule
