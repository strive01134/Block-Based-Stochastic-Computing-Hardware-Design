module ao_counter #(
    parameter SIZE_BLOCK = 4,
    parameter SIZE_AO = $clog2(SIZE_BLOCK),
    parameter SIZE_DIFF = 5
)(
    input wire clk, rstn, en, restart,
    input wire[SIZE_DIFF-1:0] diff,
    output reg[SIZE_AO-1:0] ao,
    output wire ao_inc
);
    assign ao_inc = (diff[SIZE_DIFF-1]) ? // sign bit of diff
        0 :                     // if diff is negative
        (diff > {3'b000,ao});   // if diff is positive or zero
    
    always @(posedge clk or negedge rstn) begin
        if(!rstn)           ao <= {SIZE_AO{1'b0}};
        else if(en) begin
            if(restart)     ao <= {SIZE_AO{1'b0}};
            else if(ao_inc) ao <= ao + 1'b1;
        end
    end
endmodule