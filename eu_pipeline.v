`define WORD_SIZE 16
`define BYTE_SIZE 8
`define NOP 16'b0000100100000000 // Define NOP as all zeros


module eu_pipeline (
    input clk,
    input reset,
    input instruction_ready,           // Signal indicating new instruction is ready
    input [`WORD_SIZE-1:0] instruction, // Current instruction from memory
    output reg eu_request,                  // Request signal to fetch next instruction
    output reg send_immediate,         // Immediate data to data bus
    output reg extend_signed_imm,      // Extend signed 8 bits to 16 bits
    output reg [5:0] opCode,           // Operator code
    output reg dir_or_sign,            // Direction or sign bit
    output reg wordSize,               // Operand size (byte/word)
    output reg [1:0] mod,              // Memory mode
    output reg [2:0] register,         // Register field - source
    output reg [2:0] r_or_m            // r/m field - the destination
);

    // Pipeline registers
    reg [`WORD_SIZE-1:0] IF_ID_instruction;
    reg [`WORD_SIZE-1:0] IF_ID_EX_instruction;
    reg extend_signed_imm_ID_EX, send_immediate_ID_EX;
    reg [5:0] opCode_ID_EX;
    reg dir_or_sign_ID_EX, wordSize_ID_EX;
    reg [1:0] mod_ID_EX;
    reg [2:0] register_ID_EX, r_or_m_ID_EX;

    // State tracking for `eu_request`
    reg instruction_processed;

    // Fetch Stage (IF)
    always @(posedge clk or posedge reset) begin
        
        if (reset) begin
            IF_ID_instruction <= `NOP;
            eu_request <= 0;
        end else if (instruction_ready) begin
            #1;
            $display("At time %t , instruction %b", $time, instruction);
            eu_request <= 1;
            IF_ID_instruction <= instruction; // Latch instruction from memory
            // $display("FETCH stage: Instruction fetched: %b at time %t", instruction, $time);
        end else begin
            // Inject a NOP when no valid instruction is available
            IF_ID_instruction <= `NOP;
            eu_request <= 0;
            // $display("FETCH stage: Injecting NOP at time %t", $time);
        end
    end

    // Decode Stage (ID)
    always @(posedge clk or posedge reset) begin
        $display("At time %t , fetched instruction %b", $time,IF_ID_instruction);
        if (reset) begin
            $display("At time %t reset been trigger", $time);
            opCode_ID_EX <= 0;
            dir_or_sign_ID_EX <= 0;
            wordSize_ID_EX <= 0;
            mod_ID_EX <= 0;
            register_ID_EX <= 0;
            r_or_m_ID_EX <= 0;
            send_immediate_ID_EX <= 0;
            extend_signed_imm_ID_EX <= 0;
            IF_ID_EX_instruction <= `NOP;
        end else begin
            // Decode the instruction
            IF_ID_EX_instruction <= IF_ID_instruction;
            if (IF_ID_instruction == `NOP) begin
                // No operation (bubble) detected
                // $display("DECODE stage: NOP detected at time %t", $time);
                opCode_ID_EX <= IF_ID_instruction[15:10]; // NOP opcode
                send_immediate_ID_EX <= 0;
                extend_signed_imm_ID_EX <= 0;
                dir_or_sign_ID_EX <= 0;
                wordSize_ID_EX <= 0;
                mod_ID_EX <= 0;
                register_ID_EX <= 0;
                r_or_m_ID_EX <= 0; 
            end else if (IF_ID_instruction[15] == 1'b1) begin
                // Immediate mode
                // $display("DECODE stage: Immediate mode at time %t", $time);
                opCode_ID_EX <= {IF_ID_instruction[14:10], IF_ID_instruction[5]};
                wordSize_ID_EX <= IF_ID_instruction[8];
                mod_ID_EX <= IF_ID_instruction[7:6];
                r_or_m_ID_EX <= IF_ID_instruction[2:0];
                if(IF_ID_instruction[8] == 1'b1) begin // if 16 operand
                    dir_or_sign_ID_EX <= 1'b1; 
                    extend_signed_imm_ID_EX <= IF_ID_instruction[9]; // 0 - not extend, 1 - signed 8 bits need extend
                end else begin
                    dir_or_sign_ID_EX <= 1'b1 ; // Ignored in immediate mode & ignore 9^th bit
                    extend_signed_imm_ID_EX <= 1'bz; // ignore (not extend)
                end
                send_immediate_ID_EX <= 1;
            end else begin
                // Register/memory mode
                // $display("DECODE stage: Register/memory mode at time %t", $time);
                opCode_ID_EX <= IF_ID_instruction[15:10];
                dir_or_sign_ID_EX <= IF_ID_instruction[9];
                wordSize_ID_EX <= IF_ID_instruction[8];
                mod_ID_EX <= IF_ID_instruction[7:6];
                register_ID_EX <= IF_ID_instruction[5:3];
                r_or_m_ID_EX <= IF_ID_instruction[2:0];
                send_immediate_ID_EX <= 0;
                extend_signed_imm_ID_EX <= 0;
                
            end
        end

    // $display("The Decode stage signal: OpCode = %b, dir_or_sign = %b, word_size = %b, mod =%b, register =%b",opCode_ID_EX, dir_or_sign_ID_EX, wordSize_ID_EX, mod_ID_EX, register_ID_EX);
    // $display("The Decode stage signal: register_or_mem = %b, send_imm = %b, extend_signal = %b\n",r_or_m_ID_EX, send_immediate_ID_EX,extend_signed_imm_ID_EX);
    end

    // Execute Stage (EX)
    always @(posedge clk or posedge reset) begin
        // $display("At time %t , decoded instruction %b", $time, IF_ID_EX_instruction);
        if (reset) begin
            // $display("At time %t: Reset at execute", $time);
            send_immediate <= 0;
            extend_signed_imm <= 0;
            opCode <= 0;
            dir_or_sign <= 0;
            wordSize <= 0;
            mod <= 0;
            register <= 0;
            r_or_m <= 0;
            eu_request <= 0;
        end else begin
            // Pass processed signals to output
            send_immediate <= send_immediate_ID_EX;
            extend_signed_imm <= extend_signed_imm_ID_EX;
            opCode <= opCode_ID_EX;
            dir_or_sign <= dir_or_sign_ID_EX;
            wordSize <= wordSize_ID_EX;
            mod <= mod_ID_EX;
            register <= register_ID_EX;
            r_or_m <= r_or_m_ID_EX;

            // Detect if an instruction is processed
            instruction_processed <= (opCode_ID_EX != `NOP);
            // Generate `eu_request` based on processing status
            eu_request <= instruction_ready || instruction_processed || reset;

            // Detect if a NOP is propagating through EX
            // if (opCode == 6'b000000) begin
            //     $display("EXECUTE stage: NOP executing at time %t", $time);
            // end else begin
            //     $display("EXECUTE stage: Valid instruction executing at time %t", $time);
            // end

            // $display("At time %t EXECUTE signal: opCode %b", $time, opCode);
            // $display("EXECUTE signal: dir_or_sign %b, wordSize %b, mod %b", dir_or_sign, wordSize, mod);
            // $display("EXECUTE signal: register %b, r_or_m %b\n", register, r_or_m);

        end
    end

endmodule