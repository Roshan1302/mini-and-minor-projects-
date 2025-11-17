///////////////////////////////////////version 0.1 ///////////////////////////////////////////////////
//`define MAX_CNT 3
//  module downsizer  #(parameter INP_DATA_WIDTH = 128,
//                              DATA_OUT_WIDTH= 32,
//                              VALID_CNT_WIDTH = 2)(
//    input [INP_DATA_WIDTH*8-1:0] inp_data,
//    input clk, rstn, 
//    input valid_in , 
//    output reg [DATA_OUT_WIDTH*8-1:0] data_out,
//    output reg out_en  
//  );
//  reg [VALID_CNT_WIDTH-1:0] valid_cnt ;
//  reg [0:`MAX_CNT] [DATA_OUT_WIDTH*8-1 :0] inp_reg;
//     // distributed input signals 
//     always @(posedge clk ,negedge rstn )
//           begin 
//             if(!rstn )
//               begin 
//                 valid_cnt <= 'b0;  
//                 out_en <= 'b0;
//               end 
//             else 
//               begin 
//                 if(valid_cnt > 'b0 )
//                   begin 
//                     valid_cnt <= valid_cnt -1'b1;
//                     out_en <= 1'b1 ;
//                   end 
//                 else 
//                   begin 
//                     if(valid_in)
//                       begin  
//                         valid_cnt <= `MAX_CNT;
//                         out_en <= 1'b1 ;
//                         inp_reg <= inp_data ;
//                       end  
//                     else
//                       out_en <= 1'b0 ;  
//                   end  
//              end
//         end      
//         assign data_out = inp_reg[valid_cnt];
//          endmodule

//////////////////////////////////////////////version 0.2 ////////////////////////////////////////
  module downsizer  #(parameter INP_DATA_WIDTH = 128,
                                DATA_OUT_WIDTH= 32,
                                VALID_CNT_WIDTH = $clog2(INP_DATA_WIDTH/DATA_OUT_WIDTH)
                                 )(
    input [INP_DATA_WIDTH*8-1:0] inp_data,
    input clk, rstn, 
    input valid_in , 
    output ready,
    output reg [DATA_OUT_WIDTH*8-1:0] data_out,
    output  out_en  
  );
  localparam MAX_CNT =VALID_CNT_WIDTH +1 ;
  reg [VALID_CNT_WIDTH-1:0] valid_cnt ;
  reg [1:MAX_CNT] [DATA_OUT_WIDTH*8-1 :0] inp_reg;
  reg data_lt;
     // distributed input signals 
     always @(posedge clk ,negedge rstn )
       begin 
         if(!rstn )
           begin 
             valid_cnt <= 'b0;  
           end 
         else 
           begin 
             if( | valid_cnt  )                  //  | valid_cnt means valid_cnt != 0 
               begin 
                 valid_cnt <= valid_cnt -1'b1;
               end 
             else 
               begin 
                 if(data_lt)
                   begin  
                     valid_cnt <= MAX_CNT;
                     inp_reg <= inp_data[INP_DATA_WIDTH*8-1 :DATA_OUT_WIDTH*8] ;
                   end  
               end  
          end
     end 
 always @*
   begin 
     data_out = 'b0 ;
     if(data_lt )
       data_out = inp_data[DATA_OUT_WIDTH*8-1:0] ;
     else if( | valid_cnt  )
       data_out = inp_reg[valid_cnt];   
   end 
   assign data_lt = ((valid_cnt=='b0) && valid_in ); 
   assign ready =  (valid_cnt=='b0) ;
   assign out_en =((valid_cnt!='b0)|data_lt);
endmodule

