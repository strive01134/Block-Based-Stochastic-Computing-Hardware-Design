module ctrl #(
    parameter SIZE_BLOCK = 4,
    parameter BIT_STATE = $clog2(SIZE_BLOCK)
)(
    input wire clk, rstn, en,
    output wire done_block,
    output reg valid_out
);
    reg[BIT_STATE-1:0] state, state_dl;
    wire[BIT_STATE-1:0] nextstate = (state==SIZE_BLOCK-1'b1) ? {BIT_STATE{1'b0}} : (state+1'b1);
    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            state       <= {BIT_STATE{1'b0}};
            state_dl    <= (SIZE_BLOCK-1'b1);
        end
        else if(en) begin
            state       <= nextstate;
            state_dl    <= state;
        end
    end
    
    reg valid_block;
    always @(posedge clk or negedge rstn) begin
        if(!rstn)   valid_block <= 1'b0;
        else if(en) begin
            if(state==(SIZE_BLOCK-1'b1))
                valid_block <= 1'b1;
        end
    end

    assign done_block = (valid_block && (state=={BIT_STATE{1'b0}}));

    always @(posedge clk or negedge rstn) begin
        if(!rstn)           valid_out <= 1'b0;
        else if(en)         valid_out <= valid_block;
        else                valid_out <= 1'b0;
    end
endmodule