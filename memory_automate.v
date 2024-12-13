`define RESULT_SIZE 20
module memory_automate (
    input wire clk,
    input wire reset,
    input wire [15:0] data_in,
    input wire load_ip,
    input wire [19:0] physical_address_reg, // for manual access
    input wire [15:0] segment,
    input wire [1:0] selector, // for selecting the type of operation - will be pass to a decoder for selection
    output reg [16 * `RESULT_SIZE - 1:0] used_address,
    output wire [15:0] data_out
);  
    wire [1:0] out_select;
    reg [1:0] out_select_reg;
    wire [15:0] instruction_pointer;
    wire [19:0] physical_address;
    reg instance_read;
    reg instance_write_enable;
    reg manual_read;
    reg manual_write_enable;

    integer i;

    mul_4_to_1 selecting_machine (
        // Default is manual_write_enable
        .in1(2'b00), // instance_read select
        .in2(2'b01), // manual_read
        .in3(2'b10), // manual_write_enable 
        .in4(2'b11), // instance_write_enable 
        .selector(selector), // from external
        .out(out_select) // to select which action will perform
    );

    InstructionPointer ipGen (
        .clk(clk),
        .reset(reset),
        .load_ip(load_ip),
        .instruction_pointer(instruction_pointer)
    );

    AddressGenerationCircuit addGen (
        .clk(clk),
        .segment(segment),
        .offset(instruction_pointer), // the IP
        .physical_address(physical_address)
    );


    memory memory_test (
        .instance_address(physical_address),
        .manual_address(physical_address_reg), // For manual access
        .data_in(data_in),
        .instance_read(instance_read),
        .instance_write_enable(instance_write_enable),
        .manual_read(manual_read),
        .manual_write_enable(manual_write_enable),
        .data_out(data_out)
    );

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            manual_read <= 0;
            manual_write_enable <= 0;
            instance_read <=0;
            instance_write_enable <= 0;
            i <= 0;
        end else begin
            i <= i + 1;
        end
    end

    always @(posedge clk or out_select or selector) begin
        // $display("At time %t the selector value %h", $time, selector);
        case(out_select)
            2'b00: instance_read <=1;
            2'b01: manual_read <= 1;
            2'b10: manual_write_enable <=1;
            default: instance_write_enable <= 1;
        endcase
    end

    always @(posedge clk or posedge instance_read or posedge manual_read or posedge instance_write_enable or posedge manual_write_enable) begin
        // $display("At time %t instance_read %b, manual_read %b, instance_write_enable %b, manual_write_enable %b", $time, instance_read,manual_read, instance_write_enable, manual_write_enable);
        if (instance_read) begin
            instance_write_enable <= 0;
            manual_read <= 0;
            manual_write_enable <= 0;
        end else if (manual_read) begin
            instance_read <= 0;
            instance_write_enable <= 0;
            manual_write_enable <= 0;
        end else if (instance_write_enable) begin
            instance_read <= 0;
            manual_read <= 0;
            manual_write_enable <= 0;
        end else if (manual_write_enable) begin
            instance_read <= 0;
            instance_write_enable <= 0;
            manual_read <= 0;
        end
    end

    always @(load_ip) begin
        $display("At time %t ! , the load_ip: %b", $time, load_ip);
    end

    always @(instruction_pointer) begin
        $display("At time %t The segemnt value %h", $time, segment);
        $display("At time %t The offset value %h", $time, instruction_pointer);
        $display("At time %t The physical_add %h",$time, physical_address);
    end

    always @(physical_address) begin // using the physical address to access the memory instantly
        $display ("At time %t The value of physical_address %h",$time,  physical_address);
        if (physical_address !== 20'hxxxxx) begin
            used_address[(i % `RESULT_SIZE) * 16 +: 16] <= physical_address;  
        end 
    end

endmodule