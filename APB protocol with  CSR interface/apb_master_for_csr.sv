
module apb_master_for_csr( 
    input logic prstn, 
    input logic pclk,
    
    input  logic [7:0] trf_addr,
    input  logic [7:0] trf_wdata, 
    input  logic       trf_valid, 
    output logic       trf_rdata_valid,	
    output logic [7:0]trf_rdata,
    input  logic [1:0]trf_enc, // trf_enc:tracsfer_encod 2'b10 -read ,2'b01wr
    
    input  logic [7:0]prdata,
    input  logic      pready,
    input  logic      pslverr,
    output logic [7:0]paddr,
    output logic      pwrite,
    output logic [7:0]pwdata,
    output logic      psel,
    output logic      penable
    );

parameter IDLE = 2'b01,
          SETUP = 2'b10,
          ACCESS = 2'b11;
reg [1:0] cs, ns;
wire valid ;
assign valid = trf_valid &&(trf_enc==2'b01||trf_enc==2'b10);
always @(posedge pclk)
	begin
   	if (!prstn) 
   	    begin 
            cs <= IDLE;
		    paddr <= 8'b0;
            pwdata <= 8'b0;
            pwrite <= 1'b0;
         end    
	else 
        cs <= ns;
   end
always @(posedge pclk)
 begin 
   if ((cs == IDLE && valid) || (cs == ACCESS && pready && valid)) begin
       paddr  <= trf_addr;
       pwdata <= trf_wdata;
       if (trf_enc == 2'b01)
           pwrite <= 1'b1;
       else if (trf_enc == 2'b10)
           pwrite <= 1'b0;
   end
 end
always @(*) 
begin
    case (cs)
        IDLE:  begin
                ns = IDLE;
                if(valid)
                    ns = SETUP;
              	end 
        SETUP:	begin
            		ns = ACCESS;
              	end
        ACCESS:begin
               	 if (pready && valid) 
               	    ns = SETUP;
			     else if (pready && !trf_valid) 
               	    ns = IDLE;
			     else 
               	    ns = ACCESS;
                end
    endcase
end
assign psel = (cs != IDLE); // |(cs)
assign penable =(cs == ACCESS); // &(cs)
assign trf_rdata_valid  =(penable && ~pwrite );
assign trf_rdata = trf_rdata_valid ? prdata : 8'b0; 
endmodule