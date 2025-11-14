//`timescale 1ns/1ps

//module order_independent_summing_tree #(
//    parameter NUM_INPUTS = 8,
//    parameter DATA_WIDTH = 32
//)(
//    input  wire clk,
//    input  wire rst_n,

//    // Interface for unordered inputs
//    input  wire valid_in,
//    input  wire [DATA_WIDTH-1:0] data_in,
//    output wire ready_out,   // To signal if we can accept a new input

//    // Output interface for the final sum
//    output wire [DATA_WIDTH+$clog2(NUM_INPUTS)-1:0] sum_out,
//    output wire sum_valid
//);

//    // 1. INPUT CAPTURE STAGE
//    reg [DATA_WIDTH-1:0] input_registers [NUM_INPUTS-1:0];
//    reg [NUM_INPUTS-1:0] valid_flags;
//    reg [$clog2(NUM_INPUTS):0] inputs_received_count;

//    wire all_inputs_received = (inputs_received_count == NUM_INPUTS);
//     assign ready_out = ~all_inputs_received;

//    // Find first empty slot
//    integer first_empty_slot;
//    always @(*) begin
//        first_empty_slot = -1;
//        for (int i = 0; i < NUM_INPUTS; i++) begin
//            if (valid_flags[i] == 1'b0) begin
//                first_empty_slot = i;
//                break;
//            end
//        end
//    end

//    wire [NUM_INPUTS-1:0] write_en_onehot;
//    assign write_en_onehot = (valid_in && ready_out && first_empty_slot != -1) ? (1 << first_empty_slot) : 0;

//    always @(posedge clk or negedge rst_n) begin
//        if (!rst_n) begin
//            for (int i = 0; i < NUM_INPUTS; i++) begin
//                input_registers[i] <= 0;
//                valid_flags[i] <= 1'b0;
//            end
//            inputs_received_count <= 0;
//        end else begin
//            for (int i = 0; i < NUM_INPUTS; i++) begin
//                if (write_en_onehot[i]) begin
//                    input_registers[i] <= data_in;
//                    valid_flags[i] <= 1'b1;
//                end
//            end
//            if (valid_in && ready_out)
//                inputs_received_count <= inputs_received_count + 1;
//        end
//    end

//    // 2. PIPELINED ADDER TREE (fixed for NUM_INPUTS=8)
//    reg [DATA_WIDTH:0] stage1_sum [3:0];
//    always @(posedge clk) begin
//        stage1_sum[0] <= input_registers[0] + input_registers[1];
//        stage1_sum[1] <= input_registers[2] + input_registers[3];
//        stage1_sum[2] <= input_registers[4] + input_registers[5];
//        stage1_sum[3] <= input_registers[6] + input_registers[7];
//    end

//    reg [DATA_WIDTH+1:0] stage2_sum [1:0];
//    always @(posedge clk) begin
//        stage2_sum[0] <= stage1_sum[0] + stage1_sum[1];
//        stage2_sum[1] <= stage1_sum[2] + stage1_sum[3];
//    end

//    reg [DATA_WIDTH+2:0] final_sum_reg;
//    always @(posedge clk) begin
//        final_sum_reg <= stage2_sum[0] + stage2_sum[1];
//    end

//    // 3. CONTROL LOGIC & OUTPUT
//    // Delay valid signal for 3 cycles to match adder tree latency
//    reg [2:0] all_received_pipe;
    
//    always @(posedge clk or negedge rst_n) begin
//        if (!rst_n)
//            all_received_pipe <= 3'b000;
//        else
//            all_received_pipe <= {all_received_pipe[1:0], all_inputs_received};
//    end
    
//    assign sum_valid = all_received_pipe[2];
//    assign sum_out   = final_sum_reg;

//endmodule


`timescale 1ns/1ps

module order_independent_summing_tree #(
    parameter NUM_INPUTS = 8,
    parameter DATA_WIDTH = 32
)(
    input  wire clk,
    input  wire rst_n,

    // Interface for unordered inputs
    input  wire valid_in,
    input  wire [DATA_WIDTH-1:0] data_in,
    output wire ready_out,   // To signal if we can accept a new input

    // Output interface for the final sum
    output bit [DATA_WIDTH+$clog2(NUM_INPUTS)-1:0] sum_out,
    output wire sum_valid
);

    // 1. INPUT CAPTURE STAGE
    reg [NUM_INPUTS-1:0][DATA_WIDTH-1:0] input_registers ;
    reg [NUM_INPUTS-1:0] valid_flags;
    reg [$clog2(NUM_INPUTS):0] inputs_received_count;

    wire all_inputs_received = (inputs_received_count == NUM_INPUTS);
     assign ready_out = ~all_inputs_received;

    // Find first empty slot
    reg[$clog2(NUM_INPUTS)-1:0] first_empty_slot;
    always @(*) begin
        first_empty_slot = 'b0;
        for (int i = 0; i < NUM_INPUTS; i++) begin
            if (valid_flags[i] == 1'b0) begin
                first_empty_slot = i;
                break;
            end
        end
    end

    wire [NUM_INPUTS-1:0] write_en_onehot;
assign write_en_onehot =
        (valid_in && ready_out && first_empty_slot < NUM_INPUTS)
        ? (1 << first_empty_slot)
        : '0;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
          begin
            for (int i = 0; i < NUM_INPUTS; i++) begin
                valid_flags[i] <= 1'b0;
            end
            inputs_received_count <= 'b0;
            input_registers <= 'b0 ;
          end 
        else 
         begin
            for (int i = 0; i < NUM_INPUTS; i++) begin
                if (write_en_onehot[i]) begin
                    input_registers[i] <= data_in;
                    valid_flags[i] <= 1'b1;
                end
            end
            if(all_inputs_received)
              begin 
                inputs_received_count <= 'b0;
                input_registers <= 'b0;
                valid_flags <= 'b0 ;
              end   
            else if (valid_in && ready_out)
                inputs_received_count <= inputs_received_count + 1;
        end
    end

    // 2. PIPELINED ADDER TREE (fixed for NUM_INPUTS=8)
    bit [3:0] [DATA_WIDTH:0] stage1_sum;
    bit [1:0][DATA_WIDTH+1:0] stage2_sum ;    
    bit [DATA_WIDTH+2:0] final_sum_reg;
    bit stage3_valid;
    bit stage2_valid ,stage1_valid;
    always @(posedge clk) begin
      if (!rst_n) begin
        stage1_sum <= 'b0 ;
        stage2_sum <= 'b0 ;
        final_sum_reg  <= 'b0 ;
        stage2_valid   <= 'b0 ;
        stage1_valid   <= 'b0 ;
        stage3_valid  <= 'b0 ;
      end 
      else 
        begin 
          if(all_inputs_received)begin 
            stage1_sum[0] <= input_registers[0] + input_registers[1];
            stage1_sum[1] <= input_registers[2] + input_registers[3];
            stage1_sum[2] <= input_registers[4] + input_registers[5];
            stage1_sum[3] <= input_registers[6] + input_registers[7];
            stage1_valid <= 1'b1 ;
           end
          else 
           stage1_valid <= 1'b0 ;
           
          if(stage1_valid) begin  
            stage2_sum[0] <= stage1_sum[0] + stage1_sum[1];
            stage2_sum[1] <= stage1_sum[2] + stage1_sum[3];
            stage2_valid  <= 'b1 ;
           end
          else 
           stage2_valid <= 1'b0 ; 
        
          if (stage2_valid)begin   
            final_sum_reg <= stage2_sum[0] + stage2_sum[1];
            stage3_valid   <='b1 ;
           end 
           else 
             stage3_valid <= 1'b0 ;
     end   
   end     
   
    assign sum_valid = stage3_valid  ;
    assign sum_out   = final_sum_reg;
endmodule


