`timescale 1ns / 1ps

module d_flip_flop_tb;

    reg D;
    reg clk;
    reg set;      // NOTUN - declare korte hobe
    reg reset;    // NOTUN - declare korte hobe
    wire Q;

    // Instantiate D Flip-Flop
    d_flip_flop DUT (
        .D(D),
        .clk(clk),
        .set(set),      // NOTUN - port connect
        .reset(reset),  // NOTUN - port connect
        .Q(Q)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Test sequence
    initial
    begin

        // Initial values
        clk = 0;
        D = 0;
        set = 0;      // NOTUN
        reset = 1;    // NOTUN - shuru-tei reset diye Q=0 e newa
        #8 reset = 0; // NOTUN - reset chere daw, normal operation shuru

        // Test 1
        #10 D = 1;

        // Test 2
        #10 D = 0;

        // Test 3
        #10 D = 1;

        // Test 4
        #10 D = 1;

        // Test 5
        #10 D = 0;

        // Test 6 - reset test (NOTUN)
        #10 reset = 1;   // D=0 thakleo Q shathe-shathe force 0 hobe
        #5  reset = 0;

        // Test 7 - set test (NOTUN)
        #5  set = 1;     // Q shathe-shathe force 1 hobe
        #5  set = 0;

        #10 $finish;

    end

endmodule