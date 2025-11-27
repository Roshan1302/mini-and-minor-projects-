//////---------------------------without TKKEP signal---------------------------------
//module AXI_stream#(parameter DATA_WIDTH= 8,
//                             PACKET_LENGTH = 8)(
//    input   logic clk,
//    input   logic rstn,
//    input   logic vld_in,
//    input   logic [DATA_WIDTH-1:0] din,
//    input   logic t_ready,
//    output  logic t_valid,
//    output  logic[DATA_WIDTH-1:0] t_data,
//    output  logic t_last,
//    output  logic t_keep,
//    output  logic  m_ready    );
   
//         localparam  BUS_WIDTH_BYTES = DATA_WIDTH / 8,
//                     NUM_TRANSFERS   = (PACKET_LENGTH + BUS_WIDTH_BYTES - 1) / BUS_WIDTH_BYTES,
//                     TLAST_TRANSFER  = (PACKET_LENGTH / BUS_WIDTH_BYTES)-1,
//                     COUNT_WIDTH     = $clog2(PACKET_LENGTH) - 1;

//    reg [COUNT_WIDTH:0]cnt ;
//    reg[DATA_WIDTH-1:0] reg_t_data;
//    logic stream_active;
//    logic data_latched ;
    
//    always_ff @(posedge clk or negedge rstn) begin
//        if (!rstn) begin
//            stream_active <= 1'b0;
//            cnt           <= 'b0;
//            data_latched  <= 1'b0;
//            reg_t_data    <= '0;
//        end
//        else 
//          begin
//            stream_active <= 1'b1;
//            if (t_valid) 
//              begin
//                if(!t_ready)
//                  begin 
//                    data_latched <= 1'b1;
//                    reg_t_data   <= din;
//                  end
//                else 
//                  cnt <= cnt + 1;
//            end
//        end
//    end

//    always @*
//      begin 
//      t_data = 'b0;
//        if(data_latched)
//          begin
//            t_data = reg_t_data  ;
//          end   
//        else if(t_valid )
//          begin 
//            t_data = din ;
//          end 
//      end 
// assign t_valid = stream_active && vld_in;
// assign t_last   = (cnt == PACKET_LENGTH-1'b1 );
//endmodule

//---------------------------with TKEEP signal---------------------------------
module AXI_stream #(parameter DATA_WIDTH     = 32,
                    PKT_LEN_WIDTH  = 8)(
    input   logic clk,
    input   logic rstn,

    // System/system-side input payload
    input   logic vld_in,
    input   logic [DATA_WIDTH-1:0] din,
    input   logic t_ready,
    input   logic [PKT_LEN_WIDTH-1:0] pkt_len,

    // AXI-Stream master outputs
    output  logic t_valid,
    output  logic [DATA_WIDTH-1:0] t_data,
    output  logic t_last,
    output  logic [(DATA_WIDTH/8)-1:0] t_keep,

    // Back-pressure to system (de-assert when holding previous data)
    output  logic m_ready
);
// pkt_len  :   user inp or from system to master  (value provoided from tb )  
    // Derived constants
    localparam int BUS_BYTES   = DATA_WIDTH / 8;
    localparam int MAX_PKT     = (1 << PKT_LEN_WIDTH);

    // Internal registers
    logic [DATA_WIDTH-1:0] reg_t_data;
    logic stream_active;
    logic data_latched;
    logic [$clog2(MAX_PKT):0] cnt;
    // Number of beats required for given packet length
    logic [$clog2(MAX_PKT)-1:0] tlast_transfer;
// tkeep generation combo logic //
    tkeep_gen t_keep_instance (
    .tlast(t_last),
    .tkeep(t_keep),
    .pkt_len(pkt_len));
    
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) 
          begin
            stream_active <= 'b0;
            cnt           <= 'b0;
            data_latched  <= 'b0;
            reg_t_data    <= 'b0;
          end
        else 
          begin
            stream_active <= 1'b1;
            if (t_valid) 
              begin
                if(!t_ready)
                  begin 
                    data_latched <= 1'b1;
                    reg_t_data   <= din;
                  end
                else 
                  begin 
                    data_latched <= 1'b0;
                    if(cnt == tlast_transfer)
                      cnt <= 'b0 ;
                    else  
                      cnt <= cnt + 1'b1;
                  end 
            end
        end
    end
// // Data Mux: hold vs new
    always_comb
      begin 
        t_data = 'b0;
        if(data_latched) // master is holding data     
          begin
            t_data = reg_t_data  ;
          end   
        else if(t_valid )
          begin 
            t_data = din ;
          end 
      end 
   assign tlast_transfer = (pkt_len - 1) >> $clog2(BUS_BYTES);
   assign t_valid = stream_active && vld_in;    
   assign t_last = (cnt == tlast_transfer);
   assign m_ready = ~data_latched ;
endmodule

