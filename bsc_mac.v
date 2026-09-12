`define OUR TRUE

module bsc_mac #(
    parameter SIZE_BLOCK = 4,
    parameter SIZE_POS = 3,
    parameter SIZE_NEG = 2,
    parameter SIZE_AP = $clog2(SIZE_BLOCK*SIZE_POS+1),  //ceil(log2(4*3+1))=4
    parameter SIZE_AN = $clog2(SIZE_BLOCK*SIZE_NEG+1),  //ceil(log2(4*2+1))=4
    parameter SIZE_DIFF = ((SIZE_AP>=SIZE_AN) ? SIZE_AP: SIZE_AN) + 1 // 5
    `ifdef OUR
    ,parameter SIZE_AO = $clog2(SIZE_BLOCK)+1,          // 3
    parameter SIZE_PSI = SIZE_DIFF+1,                   // 6
    parameter SIZE_PHI = SIZE_PSI//SIZE_AO+1// 3
    `endif
)(
    input wire clk, rstn, en,
    input wire[SIZE_POS-1:0] pos0_0, pos0_1, pos1_0, pos1_1, // SIZE_POS bit serial input (2X2 EA)
    input wire[SIZE_NEG-1:0] neg0_0, neg0_1, neg1_0, neg1_1, // SIZE_NEG bit serial input (2X2 EA)
    output wire valid_out, 
    output wire[1:0] sign, out,
    output wire final_value
);
    wire done_block;
    ctrl #(.SIZE_BLOCK(SIZE_BLOCK)) ctrl_i(
        .clk(clk), .rstn(rstn), .en(en),
        .done_block(done_block), .valid_out(valid_out)
    );

    // SC Multiplier for block 0: AND Gate
    wire[SIZE_POS-1:0] pos0 = pos0_0 & pos0_1;
    wire[SIZE_NEG-1:0] neg0 = neg0_0 & neg0_1;
    // SC Multiplier for block 1: AND Gate
    wire[SIZE_POS-1:0] pos1 = pos1_0 & pos1_1;
    wire[SIZE_NEG-1:0] neg1 = neg1_0 & neg1_1;

    `ifdef OUR
    wire[SIZE_DIFF-1:0] apminusan0, apminusan1;
    wire[SIZE_AO-1:0] ao0, ao1;
    `endif
    wire[1:0] temp;
    
    `ifdef OUR
    wire[$clog2(SIZE_BLOCK+1)-1:0] phi_0, phi_1;
    `endif
    // BSC Adder Block 0
    bsc_add #(
        .SIZE_BLOCK(SIZE_BLOCK), .SIZE_POS(SIZE_POS), .SIZE_NEG(SIZE_NEG),
        .SIZE_AP(SIZE_AP), .SIZE_AN(SIZE_AN), .SIZE_DIFF(SIZE_DIFF)
    ) bsc_add_0_i (
        .clk(clk), .rstn(rstn), .en(en), .done_block(done_block),
        .posin(pos0), .negin(neg0),
        `ifdef OUR
        .apminusan(apminusan0), .ao(ao0), .phi(phi_0),
        `endif
        .sign(sign[0]), .out(temp[0])
    );
    // BSC Adder Block 1
    bsc_add #(
        .SIZE_BLOCK(SIZE_BLOCK), .SIZE_POS(SIZE_POS), .SIZE_NEG(SIZE_NEG),
        .SIZE_AP(SIZE_AP), .SIZE_AN(SIZE_AN), .SIZE_DIFF(SIZE_DIFF)
    ) bsc_add_1_i (
        .clk(clk), .rstn(rstn), .en(en), .done_block(done_block),
        .posin(pos1), .negin(neg1),
        `ifdef OUR
        .apminusan(apminusan1), .ao(ao1), .phi(phi_1),
        `endif
        .sign(sign[1]), .out(temp[1])
    );

    `ifndef OUR
    assign out = temp;
    
    `else
    
    // psi generation: add ap, subtract an from each block, only at final cycle(done_block).
    reg[SIZE_PSI-1:0] psi;// 6bits
    wire[SIZE_PSI-1:0] psi_temp = {apminusan0[SIZE_DIFF-1],apminusan0}
                                 + {apminusan1[SIZE_DIFF-1],apminusan1};
    always @(posedge clk or negedge rstn) begin
        if(!rstn)           psi <= {SIZE_PSI{1'b0}}; // 000000
        else if(en)
            if(done_block)  psi <= psi_temp;
    end

    // phi generation: add ao from each block, selected by sign, on done_block.
    wire[$clog2(SIZE_BLOCK+1):0] phi_init = {phi_0[$clog2(SIZE_BLOCK+1)-1],phi_0} + {phi_1[$clog2(SIZE_BLOCK+1)-1],phi_1};
    reg[SIZE_PHI-1:0] phi;
    
    wire correction = $signed(psi) > $signed(phi);
    always @(posedge clk or negedge rstn) begin
        if(!rstn)               phi <= {SIZE_PHI{1'b0}};
        else if(en) begin
            if(done_block)      phi <= {{(SIZE_PHI-($clog2(SIZE_BLOCK+1)+1)){phi_init[$clog2(SIZE_BLOCK+1)]}},phi_init};
            else if(correction) phi <= phi+2'b10;   
        end
    end

    // OUR corrected output generation
    always @(posedge clk or negedge rstn) begin
        if(!rstn)               phi <= {SIZE_PHI{1'b0}};
        else if(en) begin
            if(done_block)      phi <= {{(SIZE_PHI-($clog2(SIZE_BLOCK+1)+1)){phi_init[$clog2(SIZE_BLOCK+1)]}},phi_init};
            else if(correction) phi <= phi+2'b10;   
        end
    end
    `endif

endmodule