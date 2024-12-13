module tb_eu_reg_alu_memory_pipeline_efficiency();
    // Parameters
    `define WORD_SIZE 16
    `define RESULT_SIZE 20

    wire clk;
    reg reset;
    reg [31:0] instruction_and_imm;
    wire [`WORD_SIZE-1:0] result;
    wire [`WORD_SIZE-1:0] status;
    reg [`WORD_SIZE-1:0] alu_status;
    reg [`WORD_SIZE-1:0] result_store;
    wire [`WORD_SIZE-1:0] result_flag;

    reg load_ip;
    reg [19:0] physical_address_reg;
    reg [15:0] segment;
    reg [1:0] selector;
    wire [16 * `RESULT_SIZE - 1:0] used_address;
    wire [15:0] data_out;

    ClockGenerator clk_gen (
        .clk(clk)
    );

    eu_reg_alu test_era (
        .clk(clk),
        .reset(reset),
        .instruction_and_imm(instruction_and_imm),
        .result(result),
        .status(status)
    );

    // memory_automate memory_test (
    //     .clk(clk),
    //     .reset(reset),
    //     .data_in(result_store),
    //     .load_ip(load_ip),
    //     .physical_address_reg(physical_address_reg),
    //     .segment(segment),
    //     .selector(selector),
    //     .used_address(used_address),
    //     .data_out(data_out)
    // );

    flag_reg flag (
        .reset(reset),
        .alu_status(alu_status),
        .result_flag_sig(result_flag)
    );

    integer i, completed_instructions;
    reg [31:0] i_and_i[0:6];
    integer start_time, end_time;

    initial begin
        // Define instructions (example provided in original code)
        i_and_i[0] = {1'b1, 5'b00000, 1'b0, 1'b0, 2'b00, 1'b1, 2'b00, 3'b000, 16'h01}; // MOV AL, 0x01
        i_and_i[1] = {1'b1, 5'b00000, 1'b0, 1'b1, 2'b00, 1'b1, 2'b00, 3'b000, 16'h1234}; // MOV AX, 0x1234
        i_and_i[2] = {1'b1, 5'b00000, 1'b0, 1'b1, 2'b00, 1'b1, 2'b00, 3'b001, 16'h1256}; // MOV BX, 0x1256
        i_and_i[3] = {1'b1, 5'b00000, 1'b0, 1'b0, 2'b00, 1'b1, 2'b00, 3'b001, 16'h02};   // MOV AH, 0x02
        i_and_i[4] = {16'b0, 6'b010000, 1'b0, 1'b1, 2'b01, 3'b001, 3'b000};              // ADD AX, BX
        i_and_i[5] = {16'b0, 6'b010000, 1'b0, 1'b0, 2'b01, 3'b001, 3'b000};              // ADD AL, AH
        i_and_i[6] = {16'b0, 6'b000010, 1'b0, 1'b1, 2'b01, 3'b001, 3'b000};              // OR AL, AH
    end

    initial begin
        reset = 1;
        // segment = 16'h0002;
        // selector <= 2'b11;
        completed_instructions = 0;

        // Start execution
        #10;
        reset = 0;
        // load_ip = 1;

        // Measure start time
        start_time = $time;

        // Feed instructions into pipeline
        for (i = 0; i < 7; i = i + 1) begin
            instruction_and_imm = i_and_i[i];
            $display("At time %t, feed instruction %d: %b", $time, i, instruction_and_imm);
            #10; // Simulate instruction latency
        end

        // Wait for pipeline to complete execution
        #100;

        // Measure end time
        end_time = $time;

        // Calculate results
        $display("Pipeline Execution Time: %0d ns", end_time - start_time);
        $display("Completed Instructions: %d", completed_instructions);
        $display("Throughput: %0f instructions/ns", completed_instructions / (end_time - start_time));
        $display("Cycles Per Instruction (CPI): %0f", ((end_time - start_time)) / completed_instructions);

        $finish;
    end

    always @(result) begin
        completed_instructions = completed_instructions + 1;
        $display("At time %t, instruction completed. Result: %h, Status: %b", $time, result, status);
    end
endmodule

/*
iverilog -o test.vvp Pipeline_test.v ClockGenerator.v eu_pipeline.v registers.v alu.v eu_reg_alu.v flag_reg.v  memory_automate.v memory.v InstructionPointer.v AddressGenerationCircuit.v mul_4_to_1.v
*/