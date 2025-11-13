
`define max_cyc_cnt 4
module round_robin_arb_fix_cyc (
    input wire clk,
    input wire rst,
    input wire [3:0] req,     // request 
    output reg [3:0] gnt      // grant 
);

    parameter IDLE = 3'b000, 
              S0 = 3'b001, 
              S1 = 3'b010, 
              S2 = 3'b011, 
              S3 = 3'b100;
    reg [2:0] cs, ns;         // current state and next state
    reg [2:0] cyc_cnt;        
    reg cnt_rst_to_1;
    // State transition logic
    always @(posedge clk or posedge rst) begin
        if (rst) 
            begin
                cs <= IDLE;
                gnt = 4'b0000;
                cyc_cnt <= 2'b00;
            end 
            else 
                begin
                    cs <= ns;
                    if (cnt_rst_to_1)
                        cyc_cnt <= 2'b01;
                    else 
                         cyc_cnt <= cyc_cnt + 1;
                end
    end
    // next state logic
    always @* begin
        ns = cs; // default 
        cnt_rst_to_1 = 0; // 
        gnt = 4'b0000;
        case (cs)
            IDLE: begin
                //cyc_cnt = 2'b00;
                cnt_rst_to_1 = 1;
                if (req[3]) ns = S3;
                else if (req[2]) ns = S2;
                else if (req[1]) ns = S1;
                else if (req[0]) ns = S0;
            end
            S3: begin
                gnt[3] = 1'b1;
                // Transition to the next state regardless of request duration
                if ((cyc_cnt == `max_cyc_cnt) || ~req[3]) 
                    begin
                        cnt_rst_to_1 = 1;
                        if (req[2]) ns = S2;
                        else if (req[1]) ns = S1;
                        else if (req[0]) ns = S0;
                        else ns = IDLE;
                    end
            end
            S2: begin
                gnt[2] = 1'b1;
                if (cyc_cnt == `max_cyc_cnt || ~req[2]) begin
                    
                    cnt_rst_to_1 = 1;if (req[1]) ns = S1;
                    else if (req[0]) ns = S0;
                    else if (req[3]) ns = S3;
                    else ns = IDLE;
                end
            end
            S1: begin
                gnt[1] = 1'b1;
                if (cyc_cnt == `max_cyc_cnt || ~req[1]) begin
                    cnt_rst_to_1 = 1;
                    if (req[0]) ns = S0;
                    else if (req[3]) ns = S3;
                    else if (req[2]) ns = S2;
                    else ns = IDLE;
                end
            end
            S0: begin
                gnt[0] = 1'b1;
                if (cyc_cnt == `max_cyc_cnt || ~req[0]) begin
                    cnt_rst_to_1 = 1;
                    if (req[3])  ns = S3;
                    else if (req[2]) ns = S2;
                    else if (req[1]) ns = S1;
                    else ns = IDLE;
                end
            end
        endcase
    end         
endmodule




