module d_flip_flop(
    input D,
    input clk,
    input set,
    input reset,
    output reg Q
);

always @(posedge clk or posedge set or posedge reset)
begin
    if (reset)
        Q <= 0;        // reset priority shobcheye beshi
    else if (set)
        Q <= 1;
    else
        Q <= D;
end
 
endmodule