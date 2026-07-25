`timescale 1ns/1ps

module tb_axi4_pipelined;

    // Clock & Reset
    logic clk;
    logic rstn;

    // USER INTERFACE SIGNALS
    logic [1:0]  usr_wr_rd_req;
    logic [31:0] usr_wr_addr_in;
    logic [7:0]  usr_burst_len;
    logic [1:0]  usr_wr_burst;
    logic [31:0] usr_data_in;

    logic [31:0] usr_rd_addr_in;
    logic [1:0]  usr_rd_burst;

    logic [2:0]  usr_transaction_id;
    logic        usr_data_vld_in;
    logic        aw_vld_in;
    logic        usr_wr_ready;

    // OUTPUTS
    logic [31:0] rd_data_out;
    logic        rd_data_valid;
    logic        pc_asserted;
    logic [2:0]  usr_trf_size;

    integer tc;

    //------------------------------------------
    // DUT
    //------------------------------------------
    axi4_pipelined dut (
        .clk(clk),
        .rstn(rstn),
        .usr_wr_rd_req(usr_wr_rd_req),
        .usr_wr_addr_in(usr_wr_addr_in),
        .usr_burst_len(usr_burst_len),
        .usr_wr_burst(usr_wr_burst),
        .usr_data_in(usr_data_in),
        .usr_rd_addr_in(usr_rd_addr_in),
        .usr_rd_burst(usr_rd_burst),
        .rd_data_out(rd_data_out),
        .pc_asserted(pc_asserted),
        .rd_data_valid(rd_data_valid),
        .usr_data_vld_in(usr_data_vld_in),
        .usr_wr_ready(usr_wr_ready),
        .usr_transaction_id(usr_transaction_id),
        .usr_trf_size(usr_trf_size),
        .aw_vld_in(aw_vld_in)
    );

    //------------------------------------------
    // Clock generation
    //------------------------------------------
    always #5 clk = ~clk;

    //------------------------------------------
    // WRITE TASK
    //------------------------------------------
    task automatic write_burst;
        input [31:0] addr;
        input [7:0]  len;
        integer beat;
        begin
            @(posedge clk);

            usr_wr_rd_req      = #0  2'b01;
            usr_wr_addr_in     = #0  addr;
            usr_burst_len      = #0  $urandom_range(0,3);;
            usr_wr_burst       = #0  2'b01;                // INCR
            usr_transaction_id = #0  $urandom_range(0,7);
            usr_trf_size       = #0  $urandom_range(0,2);
            aw_vld_in          = #0  1'b1;

            //--------------------------------------------------
            // W CHANNEL
            //--------------------------------------------------
            for(beat= 0; beat<=  len; beat=  beat+1)
            begin
                @(posedge clk);

                usr_data_vld_in = #0  1'b1;
                usr_data_in     = #0  $urandom;

                $display(
                    "T=  %0t AWADDR=  %h AWLEN= %0d AWSIZE=  %0d BEAT=  %0d DATA= %h",
                    $time,
                    addr,
                    len,
                    usr_trf_size,
                    beat,
                    usr_data_in
                );
            end

           

        end
    endtask

    //------------------------------------------
    // READ TASK
    //------------------------------------------
//    task read_burst(input [31:0] addr, input [7:0] len);
//        begin
//            @(posedge clk);

//            usr_wr_rd_req      = #0  2'b10;
//            usr_rd_addr_in     = #0  addr;
//            usr_burst_len      = #0  len;
//            usr_rd_burst       = #0  2'b01;
//            usr_transaction_id = #0  3'b010;

//            @(posedge clk);
//        end
//    endtask

    //------------------------------------------
    // STIMULUS
    //------------------------------------------
    initial begin

        clk = #0  0;
        rstn = #0  0;

        usr_wr_rd_req      = #0  0;
        usr_wr_addr_in     = #0  0;
        usr_wr_burst       = #0  0;
        usr_data_in        = #0  0;
        usr_rd_addr_in     = #0  0;
        usr_rd_burst       = #0  0;
        usr_transaction_id = #0  0;
        usr_data_vld_in    = #0  0;
        aw_vld_in          = #0  0;
        usr_wr_ready       = #0  1;
        usr_trf_size       = #0  0;

        //-----------------------------------
        // Reset
        //-----------------------------------
        #20;
        rstn = #0  1;

        //-----------------------------------
        // 10 WRITE TESTCASES
        //-----------------------------------
        for(tc= 0; tc<10; tc=  tc+1)
        begin

            write_burst(
                32'h0000_0000 , // Different address
                $urandom_range(0,3)      // Random AWLEN
            );

            repeat(3) @(posedge clk);
        end

        //-----------------------------------
        // End Simulation
        //-----------------------------------
        #100;
        $finish;

    end

    //------------------------------------------
    // MONITOR
    //------------------------------------------
    initial begin
        $monitor(
            "T= #0 %0t | REQ= #0 %b | AWADDR= #0 %h | AWLEN= #0 %0d | AWSIZE= #0 %0d | DATA= #0 %h | VALID= #0 %b",
            $time,
            usr_wr_rd_req,
            usr_wr_addr_in,
            usr_burst_len,
            usr_trf_size,
            usr_data_in,
            usr_data_vld_in
        );
    end

endmodule