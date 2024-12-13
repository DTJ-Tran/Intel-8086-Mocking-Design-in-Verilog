`define WORD_SIZE 16
`define ADDR_SIZE 20
`define REG_SIZE 16
module alu (
    input [`WORD_SIZE-1:0] a, b,
    input [5:0] alu_control,  // ALU operation control (add, subtract, etc.)
    input fire, // to control when should be doing the operation
    output reg [`WORD_SIZE-1:0] result,
    output reg [`WORD_SIZE-1:0] status_record // Define the status line for the ALU - s1tored in flag-reg
);

    /*   
    OF =status[12]  - overflow flag
    SF =status[8] - sign flag
    ZF =status[7]- zero flag
    AF =status[6]  - auxiliary flag
    PF =status[5]  - parity flag
    CF =status[4]  - carry flag

    DF =status[11] - direction flag
    IF =status[10]  - interrupt flag
    TF = status[9] - trap flag
    other bits in result_flags must be zero

    */
    parameter ADD_OP = 6'b010000; //  ADD operator
    parameter SUB_OP = 6'b001010; // SUB operator
    parameter AND_OP = 6'b001000; // AND operator
    parameter OR_OP =  6'b000010; // OR operator
    parameter XOR_OP = 6'b001100; // XOR operator
    parameter NOT_OP = 6'b111101; // NOT operator

    reg [`WORD_SIZE-1:0] status;
    wire [`WORD_SIZE:0] temp_res;
    assign temp_res = a + b;
    reg eight_bit_or_not;


    // Result calculation block
    always @(posedge result or posedge fire) begin
        
        $display("At time %t, operand 1: %h, operand 2: %h", $time, a, b);
        result = 16'b0; // Default result
        eight_bit_or_not = 1'b0; // Default operand width flag

        if (fire == 1'b1) begin // Check for fire signal
            // Determine operand size (8-bit or 16-bit)
            if (a[8] != 1'b0 || b[8] != 1'b0) begin
                eight_bit_or_not = 1'b1;
            end

            case (eight_bit_or_not)
                1'b1: begin // 8-bit operations
                    case (alu_control)
                        6'b010000: result = a + b; // ADD
                        6'b001010: result = a - b; // SUB
                        6'b001000: result = a & b; // AND
                        6'b000010: result = a | b; // OR
                        6'b001100: result = a ^ b; // XOR
                        6'b111101: result = ~a;    // NOT
                        default: result = 16'bz;   // Default
                    endcase
                end

                1'b0: begin // 16-bit operations
                    case (alu_control)
                        6'b010000: result = a + b; // ADD
                        6'b001010: result = a - b; // SUB
                        6'b001000: result = a & b; // AND
                        6'b000010: result = a | b; // OR
                        6'b001100: result = a ^ b; // XOR
                        6'b111101: result = ~a;    // NOT
                        default: result = 16'bz;   // Default
                    endcase
                end
            endcase
        end
    end

    always @(result) begin
        
        if (fire == 1'b1) begin 
            if (a[8] != 1'b0 | b[8] != 1'b0) begin
                eight_bit_or_not <= 1'b1;
            end else begin
                eight_bit_or_not <= 1'b0;
            end

            case(eight_bit_or_not)
                    1'b1: begin  // if 8-bit
                        case (alu_control)     
                            6'b010000: begin // ADD operation
                                status[0] = 0;
                                status[1] = 0;
                                status[2] = 0;
                                status[3] = 0;
                                status[4] = temp_res[8]; // Set Carry Flag (CF) if carry-out occurs
                                status[5] = ~^result[7:0]; // Set Parity Flag (PF) if result has an even number of 1s
                                status[6] = ((a[3] & b[3]) | ((a[3] | b[3]) & ~result[3])); // Set Auxiliary Carry Flag (AF) if carry from bit 3 to bit 4
                                status[7] = (result == 16'b0); // Set Zero Flag (ZF) if result is zero
                                status[8] = result[7]; // Set Sign Flag (SF) if the result is negative
                                status[9] = 0;
                                status[10] =0;
                                status[11] = 0;
                                status[12] = (a[7] == b[7]) && (result[7] != a[7]); // OF is set if a[7] == b[7] and result[7] != a[7]
                                status[13] = 0;
                                status[14] = 0;
                                status[15] = 0;
                            end

                            6'b001010: begin // SUB operation
                                status[0] = 0;
                                status[1] = 0;
                                status[2] = 0;
                                status[3] = 0;
                                status[4] = (a < b); // Set Carry Flag (CF) for subtraction (borrow)
                                status[5] = ~^result[7:0]; // Set Parity Flag (PF) if result has an even number of 1s
                                status[6] = ((~a[3] & b[3]) | ((~a[3] | b[3]) & result[3])); // Set Auxiliary Carry Flag (AF) for subtraction
                                status[7] = (result == 16'b0); // Set Zero Flag (ZF) if result is zero
                                status[8] = result[7]; // Set Sign Flag (SF) if result is negative
                                status[9] = 0;
                                status[10] =0;
                                status[11] = 0;
                                status[12] = (a[7] != b[7]) && (result[7] != a[7]); // Set Overflow Flag (OF) if signed overflow occurred
                                status[13] = 0;
                                status[14] = 0;
                                status[15] = 0;
                            end

                            6'b001000: begin // AND operation
                                status[0] = 0;
                                status[1] = 0;
                                status[2] = 0;
                                status[3] = 0;
                                status[4] = 0; 
                                status[5] = ~^result[7:0]; // Set Parity Flag (PF)
                                status[6] = 0; 
                                status[7] = (result == 16'b0); // Set Zero Flag (ZF)
                                status[8] = result[7]; // Set Sign Flag (SF)
                                status[9] = 0;
                                status[10] = 0;
                                status[11] = 0;
                                status[12] = 0; 
                                status[13] = 0;
                                status[14] = 0;
                                status[15] = 0;
                            end

                            6'b000010: begin // OR operation
                                status[0] = 0;
                                status[1] = 0;
                                status[2] = 0;
                                status[3] = 0;
                                status[4] = 0; 
                                status[5] = ~^result[7:0]; // Set Parity Flag (PF)
                                status[6] = 0;
                                status[7] = (result == 16'b0); // Set Zero Flag (ZF)
                                status[8] = result[7]; // Set Sign Flag (SF)
                                status[9] = 0;
                                status[10] = 0;
                                status[11] = 0;
                                status[12] = 0; 
                                status[13] = 0;
                                status[14] = 0;
                                status[15] = 0;
                            end

                            6'b001100: begin // XOR operation
                                status[0] = 0;
                                status[1] = 0;
                                status[2] = 0;
                                status[3] = 0;
                                status[4] = 0; 
                                status[5] = ~^result[7:0]; // Set Parity Flag (PF)
                                status[6] = 0;
                                status[7] = (result == 16'b0); // Set Zero Flag (ZF)
                                status[8] = result[7]; // Set Sign Flag (SF)
                                status[9] = 0;
                                status[10] = 0;
                                status[11] = 0;
                                status[12] = 0; 
                                status[13] = 0;
                                status[14] = 0;
                                status[15] = 0;
                            end

                            6'b111101: begin // NOT operation
                                status[0] = 0;
                                status[1] = 0;
                                status[2] = 0;
                                status[3] = 0;
                                status[4] = 0;
                                status[5] = ~^result[7:0]; // Set Parity Flag (PF)
                                status[6] = 0;
                                status[7] = (result == 16'b0); // Set Zero Flag (ZF)
                                status[8] = result[7]; // Set Sign Flag (SF)
                                status[9] = 0;
                                status[10] = 0;
                                status[11] = 0;
                                status[12] = 0; 
                                status[13] = 0;
                                status[14] = 0;
                                status[15] = 0;
                            end

                            default: status = 16'bz;
                        endcase
                    end
                    1'b0: begin // else 16- bit
                        
                        case (alu_control)
                            6'b010000: begin // ADD operation
                                status[0] = 0;
                                status[1] = 0;
                                status[2] = 0;
                                status[3] = 0;
                                status[4] = temp_res[16]; // Set Carry Flag (CF) if carry-out occurs
                                status[5] = ~^result[15:0]; // Set Parity Flag (PF) if result has an even number of 1s
                                status[6] = ((a[3] & b[3]) | ((a[3] | b[3]) & ~result[3])); // Set Auxiliary Carry Flag (AF) if carry from bit 3 to bit 4
                                status[7] = (result == 16'b0); // Set Zero Flag (ZF) if result is zero
                                status[8] = result[15]; // Set Sign Flag (SF) if the result is negative
                                status[9] = 0;
                                status[10] = 0;
                                status[11] = 0;
                                status[12] = (a[15] == b[15]) && (result[15] != a[15]); // OF is set if a[7] == b[7] and result[7] != a[7]
                                status[13] = 0;
                                status[14] = 0;
                                status[15] = 0;
                            end

                            6'b001010: begin // SUB operation
                                status[0] = 0;
                                status[1] = 0;
                                status[2] = 0;
                                status[3] = 0;
                                status[4] = (a < b); // Set Carry Flag (CF) for subtraction (borrow)
                                status[5] = ~^result[15:0]; // Set Parity Flag (PF) if result has an even number of 1s
                                status[6] = ((~a[3] & b[3]) | ((~a[3] | b[3]) & result[3])); // Set Auxiliary Carry Flag (AF) for subtraction
                                status[7] = (result == 16'b0); // Set Zero Flag (ZF) if result is zero
                                status[8] = result[15]; // Set Sign Flag (SF) if result is negative
                                status[9] = 0;
                                status[10] = 0;
                                status[11] = 0;
                                status[12] = (a[15] != b[15]) && (result[15] != a[15]); // Set Overflow Flag (OF) if signed overflow occurred
                                status[13] = 0;
                                status[14] = 0;
                                status[15] = 0;
                            end

                            6'b001000: begin // AND operation
                                status[0] = 0;
                                status[1] = 0;
                                status[2] = 0;
                                status[3] = 0;
                                status[4] = 0;
                                status[5] = ~^result[15:0]; // Set Parity Flag (PF)
                                status[6] = 0;
                                status[7] = (result == 16'b0); // Set Zero Flag (ZF)
                                status[8] = result[15]; // Set Sign Flag (SF)
                                status[9] = 0;
                                status[10] = 0;
                                status[11] = 0;
                                status[12] = 0;
                                status[13] = 0;
                                status[14] = 0;
                                status[15] = 0;
                            end
                            
                            6'b000010: begin // OR operation
                                status[0] = 0;
                                status[1] = 0;
                                status[2] = 0;
                                status[3] = 0;
                                status[4] = 0;
                                status[5] = ~^result[15:0]; // Set Parity Flag (PF)
                                status[6] = 0;
                                status[7] = (result == 16'b0); // Set Zero Flag (ZF)
                                status[8] = result[15]; // Set Sign Flag (SF)
                                status[9] = 0;
                                status[10] = 0;
                                status[11] = 0;
                                status[12] = 0;
                                status[13] = 0;
                                status[14] = 0;
                                status[15] = 0;
                            end

                            6'b001100: begin // XOR operation
                                status[0] = 0;
                                status[1] = 0;
                                status[2] = 0;
                                status[3] = 0;
                                status[4] = 0;
                                status[5] = ~^result[15:0]; // Set Parity Flag (PF)
                                status[6] = 0;
                                status[7] = (result == 16'b0); // Set Zero Flag (ZF)
                                status[8] = result[15]; // Set Sign Flag (SF)
                                status[9] = 0;
                                status[10] = 0;
                                status[11] = 0;
                                status[12] = 0;
                                status[13] = 0;
                                status[14] = 0;
                                status[15] = 0;
                            end

                            6'b111101: begin // NOT operation
                                status[0] = 0;
                                status[1] = 0;
                                status[2] = 0;
                                status[3] = 0;
                                status[4] = 0;
                                status[5] = ~^result[15:0]; // Set Parity Flag (PF)
                                status[6] = 0;
                                status[7] = (result == 16'b0); // Set Zero Flag (ZF)
                                status[8] = result[15]; // Set Sign Flag (SF)
                                status[9] = 0;
                                status[10] = 0;
                                status[11] = 0;
                                status[12] = 0;
                                status[13] = 0;
                                status[14] = 0;
                                status[15] = 0;
                            end

                            default: status = 16'bz;
                        endcase
                    end 
            endcase
            status_record <= status;        
        end else begin
            status_record <= 16'bz;
        end
    end
endmodule