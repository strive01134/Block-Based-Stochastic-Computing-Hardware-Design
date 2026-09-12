module fifo #(parameter SIZE_BLOCK = 4)(
    input wire clk, rstn, en,
    input wire in,
    output wire out
);
    reg[SIZE_BLOCK-1:0] data;
    always @(posedge clk or negedge rstn) begin
        if(!rstn)   data <= {SIZE_BLOCK{1'b0}}; // 0000
        else if(en) data <= {data[SIZE_BLOCK-2:0],in};
    end
    
    assign out = data[SIZE_BLOCK-1];
endmodule