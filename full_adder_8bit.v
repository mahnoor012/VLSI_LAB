module full_adder_8bit(
    input A0, A1, A2, A3, A4, A5, A6, A7,
    input B0, B1, B2, B3, B4, B5, B6, B7,
    input Cin,
    output S0, S1, S2, S3, S4, S5, S6, S7,
    output Cout
);

    wire c1, c2, c3, c4, c5, c6, c7;

    full_adder FA0 (.A(A0), .B(B0), .Cin(Cin), .Sum(S0), .Cout(c1));
    full_adder FA1 (.A(A1), .B(B1), .Cin(c1),  .Sum(S1), .Cout(c2));
    full_adder FA2 (.A(A2), .B(B2), .Cin(c2),  .Sum(S2), .Cout(c3));
    full_adder FA3 (.A(A3), .B(B3), .Cin(c3),  .Sum(S3), .Cout(c4));
    full_adder FA4 (.A(A4), .B(B4), .Cin(c4),  .Sum(S4), .Cout(c5));
    full_adder FA5 (.A(A5), .B(B5), .Cin(c5),  .Sum(S5), .Cout(c6));
    full_adder FA6 (.A(A6), .B(B6), .Cin(c6),  .Sum(S6), .Cout(c7));
    full_adder FA7 (.A(A7), .B(B7), .Cin(c7),  .Sum(S7), .Cout(Cout));

endmodule