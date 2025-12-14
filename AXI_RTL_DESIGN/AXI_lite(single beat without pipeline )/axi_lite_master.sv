`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.06.2025 10:26:10
// Design Name: 
// Module Name: practice_AXI
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


//module axi_lite_master (
////////////////input to top module  ///////////////////////////
//  input   clk,
//  input   resetn,
//  input   wr,
//  input     [3:0]  strbin  ,
//  input   [7:0] addrin,
//  input [31:0]d_in ,
//  output [31:0] d_out ,
//  output resp ,
  
//  ////////////write addr channel//////////
//  output reg m_axi_awvalid,
//  input  wire m_axi_awready,
//  output reg [7:0] m_axi_awaddr,
  
//  /////////////write addr channel ////////
//  input m_axi_wready,
//  output reg [31:0]m_axi_wdata ,
//  output reg [3:0] m_axi_wstrb, 
//  output reg m_axi_wvalid ,
  
// /////////////write responce channel ////////
// input m_axi_bvalid,
// input [1:0]m_axi_bresp,
// output reg m_axi_bready,
// ///////////////read address /////////////////
//   output reg     m_axi_arvalid,
//   input wire     m_axi_arready,
//   output reg [7: 0] m_axi_araddr,
//  ///////////////read data  /////////////////
//   input wire     m_axi_rvalid,
//   output reg     m_axi_rready,
//   input wire [31: 0] m_axi_rdata,
//   input wire [1: 0] m_axi_rresp
//);
//wire [31:0]strb_data;
//strobe_logic strobe_logic_inst (
//    .data_in(d_in ),
//    .data_out(strb_data),
//    .lane_sel(strbin)
//);
////reg [31:0] i_addrin_reg;
//  always @(posedge clk) 
//      begin
//        if (~resetn)
//          begin 
//            m_axi_awaddr <= 'b0;
//            m_axi_wvalid <='b0;
//            m_axi_awvalid <='b0;
//            m_axi_bready <= 'b0;
//            m_axi_wdata <= 'b0 ;
//            m_axi_wstrb <= 'b0 ;
//          end   
//          else if (m_axi_bready)  
//              begin 
//                if(m_axi_awready ) 
//                  begin 
//                    m_axi_awvalid <= 'b0 ;
//                    m_axi_awaddr <= 'b0;
//                  end 
//                if( m_axi_wready )
//                  begin 
//                    m_axi_wvalid <= 'b0 ;
//                    m_axi_wdata <= 'b0 ;
//                    m_axi_wstrb <= 'b0 ;
//                  end 
//                if(m_axi_bvalid)
//                    m_axi_bready <= 'b0 ;    
//              end
//        else if (wr )
//          begin 
//            m_axi_awaddr <= addrin;
//            m_axi_wdata <= strb_data ;
//            m_axi_awvalid<= 'b1;
//            m_axi_wvalid <='b1;
//            m_axi_bready <= 'b1;
//            m_axi_wstrb <= strbin ;
//          end 
//        else 
//          begin 
//            m_axi_awaddr <= 'b0;
//            m_axi_wvalid <='b0;
//            m_axi_awvalid <='b0;
//            m_axi_bready <= 'b0;
//            m_axi_wdata <= 'b0 ;
//            m_axi_wstrb <= 'b0 ;
//          end  
//      end
//endmodule

module axi_lite_master (
//////////////addr channel ///////////////////////////
  input   clk,
  input   resetn,
  input   wr,
  input     [3:0]  strbin  ,
  input   [2:0] addrin,
  input [31:0]d_in ,
  output [31:0] d_out ,
  output [1:0]resp ,
  
  ////////////write addr channel//////////
  output reg m_axi_awvalid,
  input  wire m_axi_awready,
  output reg [2:0] m_axi_awaddr,
  
  /////////////write addr channel ////////
  input m_axi_wready,
  output reg [31:0]m_axi_wdata ,
  output reg [3:0] m_axi_wstrb, 
  output reg m_axi_wvalid ,
  
 /////////////write responce channel ////////
 input m_axi_bvalid,
 input [1:0]m_axi_bresp,
 output reg m_axi_bready,
 ///////////////read address /////////////////
   output reg     m_axi_arvalid,
   input wire     m_axi_arready,
   output reg [2: 0] m_axi_araddr,
  ///////////////read data  /////////////////
   input wire     m_axi_rvalid,
   output reg     m_axi_rready,
   input wire [31: 0] m_axi_rdata,
   input wire [1: 0] m_axi_rresp
);
logic wdata_ready ,awaddr_ready ; 
logic  write_handshake;
logic [31:0]strb_data;
logic  read_status ,write_status;
logic busy ;
assign busy = (read_status | write_status);
  always @(posedge clk) 
      begin
        if (~resetn)
          begin 
            m_axi_awaddr <= 'b0;
            m_axi_wvalid <='b0;
            m_axi_awvalid <='b0;
            m_axi_bready <= 'b0;
            m_axi_wdata <= 'b0 ;
            m_axi_wstrb <= 'b0 ;
            read_status <= 'b0 ;
            write_status<= 'b0 ;
          end   
          else if (write_status)  
              begin 
                if (m_axi_awvalid && m_axi_awready)
                  m_axi_awvalid <= 1'b0;
              
              if (m_axi_wvalid && m_axi_wready)
                  m_axi_wvalid <= 1'b0;
              
              // Only drop BREADY after handshake
              if (m_axi_bvalid && m_axi_bready)
                 begin 
                  m_axi_bready <= 1'b0;
                  write_status <= 1'b0;
                 end 
              end
              
        else if (wr && (~write_status)&& (~read_status) &&(|strbin)) //need to wait until write or read operation complete
          begin 
            m_axi_awaddr <= addrin;
            m_axi_wdata <= d_in  ;
            m_axi_awvalid<= 'b1;
            m_axi_wvalid <='b1;
            m_axi_bready <= 'b1;
            m_axi_wstrb <= strbin ;
            write_status<= 1'b1 ;
          end 
      end

//      /////////////////////////  reading ///////////////
  always@(posedge clk)
    begin 
      if(~resetn )
        begin 
          m_axi_arvalid <= 'b0 ;
          m_axi_araddr <= 'b0;  
          m_axi_rready <= 'b0 ;
        end 
      else if (read_status)  
          begin 
            if(m_axi_arready ) 
              begin 
                m_axi_arvalid <= 'b0 ;
//                m_axi_araddr <= 'b0;
                m_axi_rready <= 'b1 ;
              end 
            if(m_axi_rvalid && m_axi_rready)
              begin 
                m_axi_rready <= 'b0 ;
                read_status <= 'b0 ;
              end 
          end
      else if (~wr &&(~write_status)&&(~read_status) ) //need to wait until write or read operation complete
        begin 
          m_axi_araddr <= addrin;
          m_axi_arvalid<= 'b1;
          read_status <= 'b1 ;
        end   
    end     
   assign  d_out = m_axi_rdata;
   assign resp = m_axi_rresp;
   
       
endmodule
