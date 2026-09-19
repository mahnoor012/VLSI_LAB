`timescale 1ns / 1ps

module full_adder_tb;

    // Inputs
    reg A;
    reg B;
    reg Cin;

    // Outputs
    wire Sum;
    wire Cout;

    // Instantiate Full Adder
    full_adder uut (
        .A(A),
        .B(B),
        .Cin(Cin),
        .Sum(Sum),
        .Cout(Cout)
    );

    // Test inputs
    initial begin

        A = 0; B = 0; Cin = 0; #10;  // 000
        A = 0; B = 0; Cin = 1; #10;  // 001
        A = 0; B = 1; Cin = 0; #10;  // 010
        A = 0; B = 1; Cin = 1; #10;  // 011
        A = 1; B = 0; Cin = 0; #10;  // 100
        A = 1; B = 0; Cin = 1; #10;  // 101
        A = 1; B = 1; Cin = 0; #10;  // 110
        A = 1; B = 1; Cin = 1; #10;  // 111

        $finish;

    end

endmodule