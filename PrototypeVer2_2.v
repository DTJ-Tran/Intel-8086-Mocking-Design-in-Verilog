`define WORD_SIZE 16
`define RESULT_SIZE 20
module tb_eu_reg_alu_memory ();
    // Parameters
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

    memory_automate memory_test (
        .clk(clk),
        .reset(reset),
        .data_in(result_store),
        .load_ip(load_ip),
        .physical_address_reg(physical_address_reg),
        .segment(segment),
        .selector(selector),
        .used_address(used_address),
        .data_out(data_out)
    );

    flag_reg flag (
        .reset(reset),
        .alu_status(alu_status),
        .result_flag_sig(result_flag)
    );

    integer i;
    reg [31:0] i_and_i[0:6];

    initial begin
        // Define mod = 00 -> immediate - register
        // mod = 01 -> register - register mode
        i_and_i[0] = {1'b1, 5'b00000, 1'b0, 1'b0 ,2'b00, 1'b1, 2'b00, 3'b000 ,16'h01}; // MOV AL, 0x01 (8-bit immediate)
        i_and_i[1] = {1'b1, 5'b00000, 1'b0, 1'b1 ,2'b00, 1'b1, 2'b00, 3'b000 ,16'h1234}; // MOV AX, 0x1234
        i_and_i[2] = {1'b1, 5'b00000, 1'b0, 1'b1 ,2'b00, 1'b1, 2'b00, 3'b001 ,16'h1256}; //  MOV BX, 0x1256
        i_and_i[3] = {1'b1, 5'b00000, 1'b0, 1'b0 ,2'b00, 1'b1, 2'b00, 3'b001 ,16'h02}; //  MOV AH, 0x02
        i_and_i[4] = {16'b0, 6'b010000, 1'b0, 1'b1, 2'b01, 3'b001 , 3'b000}; // ADD AX, BX -> AX = AX + BX
        i_and_i[5] = {16'b0, 6'b010000, 1'b0, 1'b0, 2'b01, 3'b001 , 3'b000}; // ADD AL, AH -> AL = AL + AH
        i_and_i[6] = {16'b0, 6'b000010, 1'b0, 1'b1, 2'b01, 3'b001 , 3'b000}; // OR AL, AH -> AL = AL OR AH
        /*
        1000000000100000 (0)
        1000000100100000 (1)
        1000000100100001 (2)
        1000000000100001 (3)
        0100000101001000 (4)
        0100000001001000 (5)
        */
    end

    initial begin
        reset = 1;
        segment = 16'h0002;
        selector <= 2'b11;
        #10;
        reset = 0;
        load_ip = 1;
        #5;
        instruction_and_imm = 16'b0000100100000000; // Insert NOP
        #10;
        instruction_and_imm = i_and_i[0]; 
        $display("At time %t, feed 0, i_and_i %b", $time, instruction_and_imm[31:16]);
        #10;
        instruction_and_imm = i_and_i[1]; 
        $display("At time %t, feed 1, i_and_i %b", $time, instruction_and_imm[31:16]);
        #10;
        instruction_and_imm = i_and_i[2]; 
        $display("At time %t, feed 2, i_and_i %b", $time, instruction_and_imm[31:16]);
        #10;
        instruction_and_imm = i_and_i[3]; 
        $display("At time %t, feed 3, i_and_i %b", $time, instruction_and_imm[31:16]);
        #10;
        instruction_and_imm = i_and_i[4]; 
        $display("At time %t, feed 4, i_and_i %b", $time, instruction_and_imm[15:0]);
        #10;
        instruction_and_imm = i_and_i[5]; 
        $display("At time %t, feed 5, i_and_i %b", $time, instruction_and_imm[15:0]); 
        #10;
        instruction_and_imm = i_and_i[6]; 
        $display("At time %t, feed 6, i_and_i %b", $time, instruction_and_imm[15:0]); 
        #30;
        #1;
        selector <= 2'b01;
        for (integer j  = 0; j < 13; j = j +1) begin
            #1;
            physical_address_reg <= used_address[j * 16 +: 16];
            $display("At time %t, read data %h at address %h", $time, data_out, physical_address_reg);
        end
        $finish;
    end

    always @(negedge result) begin
        $display("At time %t the result is %h",$time, result);
        $display("At time %t the status is %b", $time, status);
        alu_status <= status;
        result_store <= result;
        #1; 
        $display("At time %t the result_flag %b", $time, result_flag);
    end
endmodule

/*
 iverilog -o test.vvp PrototypeVer2_2.v ClockGenerator.v eu_pipeline.v registers.v alu.v eu_reg_alu.v flag_reg.v  memory_automate.v memory.v InstructionPointer.v AddressGenerationCircuit.v mul_4_to_1.v
*/
