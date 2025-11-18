`timescale 1ns/1ps

module tb_sync_fifo;

    parameter DEPTH = 8;
    parameter DATA_WIDTH = 8;

    reg clk;
    reg rst;               // ACTIVE-LOW reset
    reg w_en;
    reg r_en;
    reg [DATA_WIDTH-1:0] data_in;
    wire [DATA_WIDTH-1:0] data_out;
    wire f_empty;
    wire f_full;

    // Instantiate DUT
    sync_fifo #(.DEPTH(DEPTH), .DATA_WIDTH(DATA_WIDTH)) DUT (
        .clk(clk),
        .rst(rst),
        .w_en(w_en),
        .r_en(r_en),
        .data_in(data_in),
        .data_out(data_out),
        .f_full(f_full),
        .f_empty(f_empty)
    );

    // Clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;   // 100 MHz clock
    end

    // Test sequence
    initial begin
        // Initial values
        rst = 0;          // reset ACTIVE (low)
        w_en = 0;
        r_en = 0;
        data_in = 0;

        #20;
        rst = 1;          // deassert reset (FIFO starts working)

        // -----------------------------------------
        $display("\n=== TEST 1: WRITE 4 BYTES ===");
        write_byte(8'hA1);
        write_byte(8'hA2);
        write_byte(8'hA3);
        write_byte(8'hA4);

        // -----------------------------------------
        #20;
        $display("\n=== TEST 2: READ 3 BYTES ===");
        read_byte();
        read_byte();
        read_byte();

        // -----------------------------------------
        #20;
        $display("\n=== TEST 3: PARALLEL WRITE & READ (fork join) ===");
        fork
            begin
                write_byte(8'h55);
                write_byte(8'h56);
            end
            begin
                #10 read_byte();
                #10 read_byte();
            end
        join

        // -----------------------------------------
        #20;
        $display("\n=== TEST 4: FILL FIFO TO FULL ===");
        repeat(DEPTH) write_byte($random);

        // -----------------------------------------
        #20;
        $display("\n=== TEST 5: READ UNTIL EMPTY ===");
        repeat(DEPTH) read_byte();

        // -----------------------------------------
        #20;
        $display("\n=== TEST 6: UNDERFLOW CHECK ===");
        read_byte(); // should not read (empty)

        // -----------------------------------------
        #20;
        $display("\n=== TEST 7: OVERFLOW CHECK ===");
        repeat(DEPTH+1) write_byte($random); // last write must be ignored

        // -----------------------------------------
        #20;
        $display("\n=== TEST 8: READ & WRITE in SAME cycle ===");

        // preload
        write_byte(8'h11);
        write_byte(8'h22);

        @(posedge clk);
        w_en = 1;
        r_en = 1;
        data_in = 8'h99;

        @(posedge clk);
        w_en = 0;
        r_en = 0;

        $display("[%0t] SIMULTANEOUS R+W DONE. dout=%h | empty=%b full=%b",
                 $time, data_out, f_empty, f_full);

        // -----------------------------------------
        #40;
        $finish;
    end


    // ==========================
    // Tasks
    // ==========================

    task write_byte(input [7:0] val);
        begin
            @(posedge clk);
            w_en   = 1;
            data_in = val;
            @(posedge clk);
            w_en = 0;

            $display("[%0t] WRITE: %h | FULL=%b", 
                      $time, val, f_full);
        end
    endtask

    task read_byte();
        begin
            @(posedge clk);
            r_en = 1;
            @(posedge clk);
            r_en = 0;

            $display("[%0t] READ: %h | EMPTY=%b",
                     $time, data_out, f_empty);
        end
    endtask

    // Monitor
    initial begin
        $monitor("[%0t] clk=%b rst=%b w=%b r=%b din=%h dout=%h | empty=%b full=%b",
                  $time, clk, rst, w_en, r_en, data_in, data_out, f_empty, f_full);
    end

endmodule
