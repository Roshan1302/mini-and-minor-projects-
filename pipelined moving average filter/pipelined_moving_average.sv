module pipelined_moving_average #(
    parameter DATA_WIDTH   = 16,
    // Window size is fixed to 4 for this implementation
    localparam WINDOW_SIZE  = 4,
    localparam SHIFT_AMOUNT = $clog2(WINDOW_SIZE), // Will be 2
    // Sum requires extra bits to prevent overflow
    localparam SUM_WIDTH    = DATA_WIDTH + SHIFT_AMOUNT
)(
    input  wire                  clk,
    input  wire                  rst_n,

    // Input Interface
    input  wire                  valid_in,
    input  wire [DATA_WIDTH-1:0] data_in,

    // Output Interface
    output wire                  valid_out,
    output wire [DATA_WIDTH-1:0] data_out
);

    // --- Stage 1: Input Capture and Shift Register ---
    reg [WINDOW_SIZE-1:0][DATA_WIDTH-1:0] sample_shift_reg;
    reg                  valid_pipe_s1;



    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
          begin
            sample_shift_reg <= 'b0;
            valid_pipe_s1 <= 1'b0;
          end 
        else if (valid_in) 
          begin
            // Capture new sample
            sample_shift_reg <= {sample_shift_reg[DATA_WIDTH*(WINDOW_SIZE-1):0], data_in};
            // Shift old samples
            valid_pipe_s1 <= valid_in;
        end else begin
            valid_pipe_s1 <= 1'b0;
        end
    end

    wire [DATA_WIDTH-1:0] oldest_sample = sample_shift_reg[WINDOW_SIZE-1];
    wire [DATA_WIDTH-1:0] new_sample    = sample_shift_reg[0];

    // --- Stage 2: Summation ---
    reg [SUM_WIDTH-1:0] sum_reg;
    reg                 valid_pipe_s2;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sum_reg       <= 0;
            valid_pipe_s2 <= 1'b0;
        end else if (valid_pipe_s1) begin
            // new_sum = old_sum - oldest_sample + new_sample
            sum_reg       <= sum_reg - oldest_sample + new_sample;
            valid_pipe_s2 <= valid_pipe_s1;
        end else begin
            valid_pipe_s2 <= 1'b0;
        end
    end

    // --- Stage 3: Averaging (Division) and Output ---
    reg [DATA_WIDTH-1:0] data_out_reg;
    reg                  valid_out_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_out_reg  <= 0;
            valid_out_reg <= 1'b0;
        end else if (valid_pipe_s2) begin
            // Division by 4 is a right shift by 2
            data_out_reg  <= sum_reg >>> SHIFT_AMOUNT; // Use arithmetic shift
            valid_out_reg <= valid_pipe_s2;
        end else begin
            valid_out_reg <= 1'b0;
        end
    end

    assign data_out  = data_out_reg;
    assign valid_out = valid_out_reg;
endmodule
