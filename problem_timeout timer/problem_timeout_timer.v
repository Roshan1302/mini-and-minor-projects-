    `timescale 1ns / 1ps
    
    //Problem: Design a module that acts as a watchdog
    // or timeout timer. It should be configurable
    // with a timeout period. It needs a start input, 
    //and it should assert a timeout_flag if it is not 
    //reset before the period expires.
    
    module problem_timeout_timer(
    input clk ,rst,
    input [7:0]load_value ,
    input rst_flag ,
    output reg error_flag 
        );
        reg[7:0]cnt ;
        always @(posedge clk)
          begin 
            if(!rst)
              begin
                cnt <= 'b0 ;
              end 
            else    
              begin 
                cnt <= cnt-1; 
                if(!rst_flag && (!(|cnt)) )
                  begin 
                    error_flag <= 1'b1 ;
                  end 
              end   
          end 
    endmodule
