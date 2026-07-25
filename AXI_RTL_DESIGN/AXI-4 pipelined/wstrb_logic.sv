module wstrb_logic #(parameter BUS_WIDTH_BYTE = 4)(
input logic clk,
input logic rst,
input logic awvld,
input logic awready,
input logic [2:0] awsize,
input logic [31:0] addr_in,
output logic [3:0] wstrb
);

integer i;
integer start_lane;

always @(*) 
  begin
    wstrb = '0;
      if (awvld)
        begin 
          for (i = 0; i < (1 << awsize); i = i + 1) 
            begin
              wstrb[(addr_in % BUS_WIDTH_BYTE) + i] = 1'b1;
            end
        end       
  end
endmodule



//reg reg_m_axi_wdata;
// wire m_ready ;
//  always @(*) 
//  begin
//   if (~m_axi_rstn) begin
//     m_axi_awaddr    <= 'b0;
//     m_axi_bready    <= 'b0;
//     reg_m_axi_wdata <= 'b0;
//     start           <= 1'b0;
//     m_axi_awsize    <= 'b0;
//     m_axi_awid      <= 'b0;
//      m_axi_awlen    <= 'b0;
//     m_axi_awburst   <= 'b0;
//   end 
//   else begin
//     start <= 1'b1;
//     if (usr_wr_rd_req == 2'b01) 
//       begin   // write request
//       // Address channel
//         if (m_axi_awvalid) 
//           begin
//             m_axi_awid    <= usr_transaction_id;
//             m_axi_awaddr  <= usr_wr_addr_in;
//             m_axi_awsize  <= usr_trf_size;
//             m_axi_awburst <= usr_wr_burst;
//             m_axi_awlen <= usr_burst_len;
//           end
 
//       // Write data channel
//       if (m_axi_wvalid && m_axi_wready) 
//         begin
//           reg_m_axi_wdata <= usr_data_in;
//         end 
//       else if (~m_axi_wready) 
//         begin
//           reg_m_axi_wdata <= reg_m_axi_wdata; // hold value
//         end
//     end
//   end
// end