module ClockGenerator (
    output reg clk
);

    // Set the clock period (in time units)
    parameter PERIOD = 10;

    // Generate the clock signal
    initial begin
        clk = 0;  // Initialize clock to 0
        forever begin
            # (PERIOD / 2) clk = ~clk; // Toggle clock every half period
        end
    end

endmodule
