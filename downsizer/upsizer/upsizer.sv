
/////////////////////////////////////////////version0.1////////////////////////////
//  `define MAX_CNT 4
  module upsizer  #(parameter INP_DATA_WIDTH = 32,
                              DATA_OUT_WIDTH= 128,
                              VALID_CNT_WIDTH = $clog2(DATA_OUT_WIDTH/INP_DATA_WIDTH))(
    input [INP_DATA_WIDTH*8-1:0] inp_data,
    input clk, rstn, 
    input valid_in , 
    output reg [DATA_OUT_WIDTH*8-1:0] data_out,
    output  out_en
  );
    localparam MAX_CNT = VALID_CNT_WIDTH + 2 ;
    reg [VALID_CNT_WIDTH :0] valid_cnt ;
    reg [VALID_CNT_WIDTH:0] [INP_DATA_WIDTH*8-1 :0] reg_out;
    
    // Distributed input signals
    
    always @(posedge clk ,posedge rstn )
      begin 
        if(!rstn )
          begin 
            valid_cnt <= 'b0;  
            reg_out   <= 'b0;
          end 
        else 
          begin 
            if(valid_cnt == MAX_CNT && valid_in)
              begin 
                valid_cnt <= 3'b001;
                reg_out[0] <= inp_data;
//                out_en <= 1'b1 ;
              end 
            else if(valid_in)
              begin  
                reg_out[valid_cnt] <= inp_data ;
                valid_cnt  <= valid_cnt + 1'b1 ;
//                out_en <= 1'b0 ;
              end  
          end  
      end   
//    assign out_data = (valid_cnt == MAX_CNT) ? reg_out : 'b0;
    assign out_en =(valid_cnt==3'b011 && valid_in);
    always @(*)
      begin
      if(out_en)
        data_out = {reg_out,inp_data};
      else 
        data_out = 'b0 ;  
       end     
    endmodule