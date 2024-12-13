module memory(
    input wire [19:0] instance_address, // Address for instance updates
    input wire [19:0] manual_address,   // Address for manual control
    input wire [15:0] data_in,          // Data bus feed-in
    input wire instance_read,           // Read signal for instance updates
    input wire instance_write_enable,   // Write signal for instance updates
    input wire manual_read,             // Read signal for manual access
    input wire manual_write_enable,     // Write signal for manual access
    output reg [15:0] data_out          // Data bus feed-out
);
    // Define 1 MB memory with 16-bit words
    reg [15:0] mem_array [0:1023]; // 2^10 = 1,024 addresses

    // Initialize memory to zero
    integer i;
    initial begin
        for (i = 0; i < 1024; i = i + 1) begin
            mem_array[i] = 16'h0000; // Initialize to zero
        end
    end

    always @(data_in or instance_read or instance_write_enable or manual_read or manual_write_enable) begin
        // $display("At time %t, data_in: %h, instance_read: %h, instance_write_enable: %h, manual_read: %h, manual_write_enable: %h", 
        //          $time, data_in, instance_read, instance_write_enable, manual_read, manual_write_enable);
    end

    // Read and Write operations
    always @(*) begin
        // Instance Update Access
        if (instance_read && !instance_write_enable) begin
            if (instance_address < 1024) begin
                data_out = mem_array[instance_address]; // Read data
                $display("Instance Read: Address [%h] -> Data [%h]", instance_address, data_out);
            end else begin
                $display("Instance Read Error: Address [%h] out of range", instance_address);
                data_out = 16'h0000; // Default to zero on error
            end
        end else if (instance_write_enable && !instance_read) begin
            if (instance_address < 1024) begin
                mem_array[instance_address] = data_in; // Write data
                $display("Instance Write: Address [%h] <- Data [%h]", instance_address, data_in);
            end else begin
                $display("Instance Write Error: Address [%h] out of range", instance_address);
            end
        end

        // Manual Access
        if (manual_read && !manual_write_enable) begin
            if (manual_address < 1024) begin
                data_out = mem_array[manual_address]; // Read data
                $display("Manual Read: Address [%h] -> Data [%h]", manual_address, data_out);
            end else begin
                $display("Manual Read Error: Address [%h] out of range", manual_address);
                data_out = 16'h0000; // Default to zero on error
            end
        end else if (manual_write_enable && !manual_read) begin
            if (manual_address < 1024) begin
                mem_array[manual_address] = data_in; // Write data
                $display("Manual Write: Address [%h] <- Data [%h]", manual_address, data_in);
            end else begin
                $display("Manual Write Error: Address [%h] out of range", manual_address);
            end
        end

        // High Impedance if neither manual nor instance signals are active
        if (!(instance_read || instance_write_enable || manual_read || manual_write_enable)) begin
            data_out = 16'hZZZZ;
        end
    end
endmodule