module sub #(parameter BITWIDTH = 4)(
    input wire[BITWIDTH-1:0] a, b,
    output wire[BITWIDTH:0] out
);
    //assign out = a - b;
    wire[BITWIDTH-1:0] res = a + ~b + 1;
    assign out = {res[BITWIDTH-1],res}; // sign-extension
endmodule