`timescale 1ns / 1ps
//Problem: You need to design the control logic for a car's turn indicator. 
//The system has a three-position lever (LEFT, RIGHT, OFF). 
//When the lever is set to LEFT or RIGHT, 
//the corresponding lamp should blink at a 1 Hz frequency
//(0.5s on, 0.5s off). When the lever is moved to OFF, 
//the lamp should immediately turn off. The system runs on a 50 MHz clock.

module car_indicator(
input clk ,rst,
input [1:0] indicator_inp ,
output reg left_indicator,right_indicator     );
parameter IDLE=2'b00,
          LEFT =2'b01,
          RIGHT =2'b10;
reg [1:0]cs, ns ;
reg[$clog2(25000000)-1:0]cnt ;
always@(posedge clk )
  begin 
    if(!rst)
      begin 
        cnt <= 'b0;
        cs <= IDLE ;
      end 
    else 
      begin 
        cnt<= cnt+1 ;
        cs <= ns ;
        if(cnt == 24999999)
           begin 
             cnt <='b0;
             if(cs == LEFT)
               left_indicator = ~left_indicator;
             else if(cs == RIGHT )  
               right_indicator=~right_indicator;
             else 
               {left_indicator,right_indicator}<= 'b0 ;    
          end
      end 
  end 
  always@*
    begin 
      case(cs)
          IDLE :begin 
                  ns = IDLE ;
                  if(indicator_inp ==LEFT)
                    ns = LEFT;
                  else if(indicator_inp ==RIGHT)
                    ns = RIGHT ;
                end 
          LEFT :begin 
                  ns = IDLE ;
                  if(indicator_inp ==RIGHT)
                    ns = RIGHT ;
                end
          RIGHT :begin 
                  ns = IDLE ;
                  if(indicator_inp == LEFT)
                    ns = LEFT;
                end            
      endcase      
    end     
endmodule
