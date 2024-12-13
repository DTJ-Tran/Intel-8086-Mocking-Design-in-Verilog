`define WORD_SIZE 16
`define ADDR_SIZE 20
`define REG_SIZE 16
`define NOP 16'b0000100100000000 // Define NOP as all zeros
`define TEMP_SIZE 5
`define RESULT_SIZE 20

module eu_reg_alu (
    input wire clk,
    input wire reset,
    input [31:0] instruction_and_imm, 
    output [`WORD_SIZE-1:0] result, // if the data is moving to register - result == z
    output [`WORD_SIZE-1:0] status // for setting the status register
);

    /* Instruction Format:
        // first 16 bits [31:15] for instruction & next 16 bits is immediate
        // if the instruction contain no immediate - 16 bits upper being zero
    */
    reg [`WORD_SIZE-1:0] instruction;
    reg [`WORD_SIZE-1:0] immediate;
    reg [`WORD_SIZE-1:0] data_in;
    reg [2:0] r_or_m_reg;  
    reg is_reg_inst;
    reg inst_ready;
    wire [`WORD_SIZE-1:0] data_out;
    wire eu_request;
    wire send_imm;
    wire extend_sign_imm;
    wire [5:0] opCode;
    wire dir_or_sign;
    wire wordSize;
    wire [1:0] mod;
    wire [2:0] register;
    wire [2:0] r_or_m;
    reg [`WORD_SIZE-1:0] src_data, dst_data;
    reg [2:0] dest_reg;
    reg fire;
    integer j;
    reg[15:0] temporary_const [0:`TEMP_SIZE-1];

    eu_pipeline eu_test (
        .clk(clk),
        .reset(reset),
        .instruction_ready(inst_ready),
        .instruction(instruction),
        .eu_request(eu_request),
        .send_immediate(send_imm),
        .extend_signed_imm(extend_sign_imm),
        .opCode(opCode),
        .dir_or_sign(dir_or_sign),
        .wordSize(wordSize),
        .mod(mod),
        .register(register),
        .r_or_m(r_or_m)
    );

    registers registers_file (
        .reset(reset),
        .direction(dir_or_sign),
        .word_size(wordSize),
        .reg_sel(r_or_m_reg),
        .data_in(data_in),
        .data_out_signal(data_out)
    );

    alu alu_inst (
        .a(dst_data),
        .b(src_data),
        .alu_control(opCode),
        .fire(fire),
        .result(result),
        .status_record(status)
    );


    always @(posedge clk or posedge reset) begin
        if (instruction_and_imm[31:16] != 16'b0) begin
            instruction <= instruction_and_imm[31:16];
            $display("At time %t, storing %h, with j %d", $time, instruction_and_imm[15:0], j);
            $display("At time %t working with imm_inst",$time);
            if (j == 0) begin // if j = 0 -> store at zero index - declare the start
                temporary_const[j] <= instruction_and_imm[15:0];
                #1;
                $display("At time %t - const value %h, j value %d (*) ", $time, temporary_const[j],j);
            end else begin // if the value is greater than zero
                if (j % `TEMP_SIZE == 0) begin
                    temporary_const[(j % `TEMP_SIZE) + 1] <= instruction_and_imm[15:0];
                    #1;
                    $display("At time %t - const value %h, j value %d (**) ", $time, temporary_const[(j % `TEMP_SIZE) + 1], (j % `TEMP_SIZE) + 1);
                end else begin
                    temporary_const[(j % `TEMP_SIZE)] <= instruction_and_imm[15:0];
                    #1;
                    $display("At time %t - const value %h, j value %d (***) ", $time, temporary_const[j % `TEMP_SIZE], j % `TEMP_SIZE);
                end
            end
        end else begin
            $display("At time %t working with reg_inst, instruction %b",$time,instruction_and_imm);
            instruction <= instruction_and_imm[15:0];
        end
        inst_ready <= 1;
    end

    always @(mod) begin
        if (mod == 2'b00) begin
            $display("At time %t working with immediate-register", $time);
            is_reg_inst <=0;
        end else begin
            $display("At time %t working with register-register", $time);
            is_reg_inst <=1;
        end   
    end

    always @(is_reg_inst or fire) begin
        if (is_reg_inst) begin
            $display("At time %t ! the source val %b !", $time, register);
            $display("At time %t ! the destination val %b !", $time, r_or_m);
            r_or_m_reg <= register;
            dest_reg <= r_or_m; 
            #1;
            $display("At time %t the data_out (1): %h", $time, data_out);
            src_data <= data_out;
            r_or_m_reg <= dest_reg;
            #1; 
            $display("At time %t the data_out (2): %h", $time, data_out);
            dst_data <= data_out;
            fire <= 1;
            #1;
            $display("At time %t the result (3): %h", $time, result);
            $display("At time %t, the status is %b", $time, status);
            #1;
            fire <= 0;
            
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            j <= 0;
        end else begin
            j <= j+ 1;
        end
    end

    integer acess_index;
    always @(posedge clk or posedge reset) begin // Extract the data from EU processing signal
        if (reset) begin
            inst_ready <= 0;
            fire <= 0;
        end else begin // use the list of index to access
            #1;
            if (send_imm == 1'b1) begin
                $display("At time %t, the value of j ! %d", $time, j);
                $display("At time %t, Register_select %b", $time,r_or_m);
                acess_index = ((j -4) % 4) +1;
                $display("At time %t, Cast the value: %h, access position: %d ", $time,temporary_const[acess_index], acess_index);
                $display("At time %t, Cast the value: %h, access position: %d ", $time,temporary_const[acess_index+1], acess_index+1);
                data_in <= temporary_const[acess_index];
                r_or_m_reg <= r_or_m;
                #1;
                $display("At time %t, data_in %h", $time, data_in);
            end else begin
                $display("At time %t False", $time);
            end
        end
    end


endmodule