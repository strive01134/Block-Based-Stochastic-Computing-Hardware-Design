module one_counter #(
    parameter SIZE_BLOCK = 4,
    parameter SIZE_IN = 3,
    parameter SIZE_OUT = $clog2(SIZE_BLOCK * SIZE_IN+1) // 4
)(
    input wire clk, rstn, en, restart,
    input wire[SIZE_IN-1:0] in, // 3bits
    output reg[SIZE_OUT-1:0] out // // 4bits
);
    reg[$clog2(SIZE_IN+1)-1:0] sum; // 4bits
    integer i;
    always @(*) begin
        sum = {$clog2(SIZE_IN+1){1'b0}}; // 00
        for(i=0; i<SIZE_IN; i=i+1)
            sum = sum + in[i];
    end

    wire[SIZE_OUT-1:0] next_out = restart ? sum : out+sum;
    always @(posedge clk or negedge rstn) begin
        if(!rstn)       out <= {SIZE_OUT{1'b0}};
        else if(en)     out <= next_out;
    end
endmodule