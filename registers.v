`define WORD_SIZE 16
`define ADDR_SIZE 20
`define REG_SIZE 16

module registers (
    input clk,
    input reset,
    input direction,     // Dirrection bit  - 0: Import data to register, 1: Export data from register
    input word_size,      // Word size bit
    input [2:0] reg_sel,   // Selects between AX, BX, CX, DX, SP, BP, SI, DI (NEED TO DEFINE WHAT REG BEING SELECT)
    input [`WORD_SIZE-1:0] data_in,  // Data input for the selected register
    output reg [`WORD_SIZE-1:0] data_out_signal // Data output from the selected register
);
    reg [`WORD_SIZE-1:0] AX, BX, CX, DX;
    reg [7:0] AL, AH, BL, BH, CL, CH, DL, DH;
    reg doing_import;

    always @(*) begin
        $display("At time %t, the input: %h, dirrection: %b", $time, data_in, direction);
    end

    // Handle state changes for import/export operations
    always @(posedge direction or posedge doing_import or posedge reset) begin
        // Debugging register states
        #1;
        $display("Register States at time %t:", $time);
        $display("AL: %h, AH: %h, BL: %h, BH: %h, CL: %h, CH: %h, DL: %h, DH: %h", 
                 AL, AH, BL, BH, CL, CH, DL, DH);
        $display("AX: %h, BX: %h, CX: %h, DX: %h", AX, BX, CX, DX);
    end

    always @(*) begin
        $display("At time %t, dirrection: %h", $time, direction);
        if (direction == 1'b1) begin
            #1;
            $display("At time: %t, doing import, the_data: %h ", $time, data_in[7:0]);
            // Load data to selected register based on word size and reg_sel
            case ({word_size,reg_sel})
                4'b0000: AL <= data_in[7:0]; // AL (W=0 case) - 8-bit
                4'b0001: AH <= data_in[7:0]; // AH
                4'b0010: BL <= data_in[7:0]; // BL
                4'b0011: BH <= data_in[7:0]; // BH
                4'b0100: CL <= data_in[7:0]; // CL
                4'b0101: CH <= data_in[7:0]; // CH
                4'b0110: DL <= data_in[7:0]; // DL
                4'b0111: DH <= data_in[7:0]; // DH

                4'b1000: AX <= data_in; // AX (W=1 case) - 16-bit
                4'b1001: BX <= data_in; // BX
                4'b1010: CX <= data_in; // CX
                4'b1011: DX <= data_in; // DX      
            endcase        
        end
        assign doing_import = 1;
    end;


    always @(posedge reset) begin
        if (reset) begin 
            $display("At time: %t doing reset", $time);
            AX <= 16'b0;
            BX <= 16'b0;
            CX <= 16'b0;
            DX <= 16'b0;
        
            AL <= 8'b0;
            AH <= 8'b0;
            BL <= 8'b0;
            BH <= 8'b0;
            CL <= 8'b0;
            CH <= 8'b0;
            DL <= 8'b0;
            DH <= 8'b0;
            data_out_signal <= 16'b0; // Clear output on reset
        end
    end

    // Combinational block: export data from selected register  
    always @(*) begin
        if (direction == 1'b0) begin  // Export data from registers 
            $display("At time: %t, doing export", $time);
            case (({word_size,reg_sel}))
                4'b0000: data_out_signal = AL; // AL (W=0 case)
                4'b0001: data_out_signal = AH; // AH
                4'b0010: data_out_signal = BL; // BL
                4'b0011: data_out_signal = BH; // BH
                4'b0100: data_out_signal = CL; // CL
                4'b0101: data_out_signal = CH; // CH
                4'b0110: data_out_signal = DL; // DL
                4'b0111: data_out_signal = DH; // DH

                4'b1000: data_out_signal = AX; // AX (W=1 case)
                4'b1001: data_out_signal = BX; // BX
                4'b1010: data_out_signal = CX; // CX
                4'b1011: data_out_signal = DX; // DX
            endcase
        end else begin
            data_out_signal = 16'b0; // Clear output if not exporting
        end
        #1;
        $display("At time: %t, done export , the data %h", $time, data_out_signal);
        assign doing_import = 0;
end
endmodule

