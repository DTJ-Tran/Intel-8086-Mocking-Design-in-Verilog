`define WORD_SIZE 16
`define ADDR_SIZE 20
`define REG_SIZE 16
module flag_reg
    (
        input reset,
        input [`WORD_SIZE-1:0] alu_status, // the guide from ALU
        output wire [`WORD_SIZE-1:0] result_flag_sig // the flag register signal
    );
        reg [`WORD_SIZE-1:0] result_flag;  // the flag register (storing)
        
        /*
            OF =instr[12] = result_flag[11] - overflow flag
            DF =instr[11] = result_flag[10] - direction flag
            IF =instr[10] = result_flag[9] - interrupt flag
            TF = instr[9] = result_flag[8] - trap flag
            SF =instr[8] = result_flag[7] - sign flag
            ZF =instr[7] = result_flag[6] - zero flag
            AF =instr[6] = result_flag[4] - auxiliary flag
            PF =instr[5] = result_flag[2] - parity flag
            CF =instr[4] = result_flag[0] - carry flag
            other bits in result_flags must be zero
        */
        always @(*) begin    
            if (reset == 1'b1) begin 
                result_flag <= 16'b0;
            end else  begin
            result_flag[11] = alu_status[12]; // OF
            result_flag[10] = alu_status[11]; // DF
            result_flag[9] = alu_status[10]; // IF
            result_flag[8] = alu_status[9]; // TF
            result_flag[7] = alu_status[8]; // SF
            result_flag[6] = alu_status[7]; // ZF 
            result_flag[4] = alu_status[6]; // AF
            result_flag[2] = alu_status[5]; // PF
            result_flag[0] = alu_status[4]; // CF   
            end
        end
        assign result_flag_sig = result_flag; // Continues Assignment
endmodule