`define OUR TRUE

module bsc_add #(
    parameter SIZE_BLOCK = 4,
    parameter SIZE_POS = 3,
    parameter SIZE_NEG = 2,
    parameter SIZE_AP = $clog2(SIZE_BLOCK*SIZE_POS+1),  //ceil(log2(4*3+1))=4
    parameter SIZE_AN = $clog2(SIZE_BLOCK*SIZE_NEG+1),  //ceil(log2(4*2+1))=4
    parameter SIZE_DIFF = ((SIZE_AP>=SIZE_AN) ? SIZE_AP: SIZE_AN) + 1, // 5
    parameter SIZE_AOPN = $clog2(SIZE_BLOCK),           // 2
    parameter SIZE_AO = $clog2(SIZE_BLOCK)+1            // 3
)(
    input wire clk, rstn, en, done_block,
    input wire[SIZE_POS-1:0] posin,
    input wire[SIZE_NEG-1:0] negin,
    `ifdef OUR
    output wire[SIZE_DIFF-1:0] apminusan, //  5bits
    output wire[SIZE_AO-1:0] ao, // 3bits
    output wire[$clog2(SIZE_BLOCK+1)-1:0] phi,
    `endif
    output reg sign,
    output wire out
);
    wire[SIZE_AP-1:0] ap;
    wire[SIZE_AN-1:0] an;
    one_counter #(
        .SIZE_BLOCK(SIZE_BLOCK), .SIZE_IN(SIZE_POS),
        .SIZE_OUT($clog2(SIZE_BLOCK*SIZE_POS+1))
    ) ap_gen_i (
        .clk(clk), .rstn(rstn), .en(en), .restart(done_block),
        .in(posin), .out(ap)
    );
    one_counter #(
        .SIZE_BLOCK(SIZE_BLOCK), .SIZE_IN(SIZE_NEG),
        .SIZE_OUT($clog2(SIZE_BLOCK*SIZE_NEG+1))
    ) an_gen_i (
        .clk(clk), .rstn(rstn), .en(en), .restart(done_block),
        .in(negin), .out(an)
    );

    `ifndef OUR
    wire[SIZE_DIFF-1:0] apminusan;
    `endif
    wire[SIZE_DIFF-1:0] anminusap;
    sub #(.BITWIDTH(SIZE_DIFF-1)) apminusan_i (.a(ap), .b(an), .out(apminusan));
    //sub #(.BITWIDTH(4)) anminusap_i (.a(an), .b(ap), .out(anminusap));
    assign anminusap = ~apminusan + 5'b00001; // anminusap = -1* apminusan

    wire[SIZE_AOPN-1:0] aop, aon;
    wire sop, son;
    ao_counter #(.SIZE_BLOCK(SIZE_BLOCK), .SIZE_DIFF(5)) aop_counter_i(
        .clk(clk), .rstn(rstn), .en(en), .restart(done_block),
        .diff(apminusan), .ao(aop), .ao_inc(sop)
    );
    ao_counter #(.SIZE_BLOCK(SIZE_BLOCK), .SIZE_DIFF(5)) aon_counter_i(
        .clk(clk), .rstn(rstn), .en(en), .restart(done_block),
        .diff(anminusap), .ao(aon), .ao_inc(son)
    );

    wire sop_dl, son_dl;    // delayed sop and son for SIZE_BLOCK cycle using FIFO
    fifo #(.SIZE_BLOCK(SIZE_BLOCK)) fifo_sop_i(
        .clk(clk), .rstn(rstn), .en(en),
        .in(sop), .out(sop_dl)
    );
    fifo #(.SIZE_BLOCK(SIZE_BLOCK)) fifo_son_i(
        .clk(clk), .rstn(rstn), .en(en),
        .in(son), .out(son_dl)
    );
    
    `ifdef OUR;
    wire[$clog2(SIZE_BLOCK+1)-1:0] phi_p, phi_n;
    one_counter #(
        .SIZE_BLOCK(SIZE_BLOCK), .SIZE_IN(1),
        .SIZE_OUT($clog2(SIZE_BLOCK+1))
    ) sop_counter_i (
        .clk(clk), .rstn(rstn), .en(en), .restart(done_block),
        .in(sop), .out(phi_p)
    );
    one_counter #(
        .SIZE_BLOCK(SIZE_BLOCK), .SIZE_IN(1),
        .SIZE_OUT($clog2(SIZE_BLOCK+1))
    ) so_counter_i (
        .clk(clk), .rstn(rstn), .en(en), .restart(done_block),
        .in(son), .out(phi_n)
    );
    `endif

    always @(posedge clk or negedge rstn) begin
        if(!rstn)               sign <= 0;              // sign=1 if positive
        else if(en&done_block)  sign <= ~apminusan[SIZE_DIFF-1];  // apminusan[4]==0
    end
    assign out = sign ? sop_dl : son_dl;                // MUXing delayed output
    
    `ifdef OUR
    assign ao = ~apminusan[SIZE_DIFF-1] ? {1'b0,aop} : {1'b1,1'b1+~aon};
    assign phi = sign ? phi_p : phi_n;
    `endif
endmodule