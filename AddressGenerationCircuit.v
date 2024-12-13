module AddressGenerationCircuit (
    input clk,
    input [15:0] segment, // Segment address (16 bits) - get the CS
    input [15:0] offset,  // Offset address (16 bits) or IP
    output reg [19:0] physical_address // Physical address (20 bits)
);

    always @(*) begin
        // Compute physical address = (Segment * 16) + Offset
        physical_address = (segment << 4) + offset; // Shift segment left by 4 bits (multiply by 16)
       
    end
endmodule
