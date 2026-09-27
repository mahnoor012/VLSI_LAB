module register_1bit(
    input D,
    input clk,
    input set,
    input reset,
    output Q
);

d_flip_flop DFF1 (
    .D(D),
    .clk(clk),
    .set(set),
    .reset(reset),
    .Q(Q)
);

endmodule