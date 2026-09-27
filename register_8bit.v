module register_8bit(
    input D0, D1, D2, D3, D4, D5, D6, D7,
    input clk,
    input set,
    input reset,
    output Q0, Q1, Q2, Q3, Q4, Q5, Q6, Q7
);

register_1bit REG0 (.D(D0), .clk(clk), .set(set), .reset(reset), .Q(Q0));
register_1bit REG1 (.D(D1), .clk(clk), .set(set), .reset(reset), .Q(Q1));
register_1bit REG2 (.D(D2), .clk(clk), .set(set), .reset(reset), .Q(Q2));
register_1bit REG3 (.D(D3), .clk(clk), .set(set), .reset(reset), .Q(Q3));
register_1bit REG4 (.D(D4), .clk(clk), .set(set), .reset(reset), .Q(Q4));
register_1bit REG5 (.D(D5), .clk(clk), .set(set), .reset(reset), .Q(Q5));
register_1bit REG6 (.D(D6), .clk(clk), .set(set), .reset(reset), .Q(Q6));
register_1bit REG7 (.D(D7), .clk(clk), .set(set), .reset(reset), .Q(Q7));

endmodule