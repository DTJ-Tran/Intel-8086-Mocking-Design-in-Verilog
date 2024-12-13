module InstructionPointer (
    input wire clk,
    input wire reset,
    input wire load_ip,                   // Control signal to load new IP
    output reg [15:0] instruction_pointer  // Current instruction pointer
);
    // reg [15:0] ip_reg;

    initial begin
        instruction_pointer = 16'b0;
    end

    always @(posedge clk) begin
        // 
        if (reset) begin
            instruction_pointer <= 16'b0000_0000_0000_0000;
        end
        if (load_ip) begin
            instruction_pointer <= instruction_pointer + 1; // Increment IP on each clock
        end
        // $display("At time %t, the value of IP: %h",$time, instruction_pointer);
    end
   
endmodule

