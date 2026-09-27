`timescale 1ns / 1ps

module register_1bit_tb;

    reg D;
    reg clk;
    reg set;      // NOTUN
    reg reset;    // NOTUN

    wire Q;

    register_1bit uut (
        .D(D),
        .clk(clk),
        .set(set),      // NOTUN
        .reset(reset),  // NOTUN
        .Q(Q)
    );

    // Clock generation
    initial begin
        clk = 0;

        forever #5 clk = ~clk;
    end

    // Test cases
    initial begin

        // Initial reset
        set = 0;
        reset = 1;    // NOTUN - shuru-tei Q=0 e newa
        D = 0;
        #8 reset = 0; // NOTUN - reset chere daw

        // Test 1
        D = 0;
        #10;

        // Test 2
        D = 1;
        #10;

        // Test 3
        D = 0;
        #10;

        // Test 4
        D = 1;
        #10;

        // Test 5
        D = 0;
        #10;

        // Test 6 - reset test (NOTUN)
        reset = 1;
        #10;
        reset = 0;

        // Test 7 - set test (NOTUN)
        set = 1;
        #10;
        set = 0;

        $finish;

    end

endmodule