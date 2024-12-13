module mul_4_to_1 (
    input [1:0] in1,
    input [1:0] in2,
    input [1:0] in3,
    input [1:0] in4,
    input [1:0] selector,
    output reg[1:0] out
);

    always @(*) begin
        // $display("At time %t the selector value %b", $time, selector);
        case (selector) 
            2'b00: out <= in1;
            2'b01: out <= in2;
            2'b10: out <= in3;
            default: out <= in4;
        endcase
    end
endmodule