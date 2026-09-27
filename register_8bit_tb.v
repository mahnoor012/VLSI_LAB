`timescale 1ns / 1ps

module register_8bit_tb;

    // reg variabel for input
    reg D0, D1, D2, D3, D4, D5, D6, D7;
    reg clk;
    reg set;      // NOTUN
    reg reset;    // NOTUN

    //wire variable for output
    wire Q0, Q1, Q2, Q3, Q4, Q5, Q6, Q7;

    // add 8bit register module (UUT)
    register_8bit uut (
        .D0(D0), .D1(D1), .D2(D2), .D3(D3), 
        .D4(D4), .D5(D5), .D6(D6), .D7(D7),
        .clk(clk),
        .set(set),      // NOTUN
        .reset(reset),  // NOTUN
        .Q0(Q0), .Q1(Q1), .Q2(Q2), .Q3(Q3), 
        .Q4(Q4), .Q5(Q5), .Q6(Q6), .Q7(Q7)
    );

    // clk genaration (clk change after 5 ns)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // test case
    initial begin
        // initial reset - shob Q ke 0 e newa (NOTUN)
        set = 0;
        reset = 1;
        D0=0; D1=0; D2=0; D3=0; D4=0; D5=0; D6=0; D7=0;
        #8 reset = 0;   // reset chere daw, normal operation shuru

        // all input,D=0
        D0=0; D1=0; D2=0; D3=0; D4=0; D5=0; D6=0; D7=0;
        #10; // wait 10ns for see 1 clk cycle (low then h)

        // D1=D3=D5=D7=1
        D0=0; D1=1; D2=0; D3=1; D4=0; D5=1; D6=0; D7=1;
        #10;

        // D0=D2=D4=D6=1
        D0=1; D1=0; D2=1; D3=0; D4=1; D5=0; D6=1; D7=0;
        #10;

        // all inputs are D=1
        D0=1; D1=1; D2=1; D3=1; D4=1; D5=1; D6=1; D7=1;
        #10;

        // reset test - shob D=1 thakleo Q shob force 0 hobe (NOTUN)
        reset = 1;
        #10;
        reset = 0;

        // set test - Q shob force 1 hobe (NOTUN)
        set = 1;
        #10;
        set = 0;

        $finish; 
    end

endmodule

//red line r ashbe na shuru-te, karon reset diye Q already 0-e set kora hocche