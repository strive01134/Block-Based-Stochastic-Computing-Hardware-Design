module tb_bsc_mac;
    //parameter NUM_BLOCK = 2;
    parameter SIZE_BLOCK = 4;
    parameter SIZE_POS = 3;
    parameter SIZE_NEG = 2;

    reg clk, rstn, en;
    reg[SIZE_POS-1:0] pos0_0, pos0_1, pos1_0, pos1_1;
    reg[SIZE_NEG-1:0] neg0_0, neg0_1, neg1_0, neg1_1;
    wire valid_out;
    wire[1:0] sign, out;

    bsc_mac #(
        .SIZE_BLOCK(SIZE_BLOCK),
        .SIZE_POS(SIZE_POS), .SIZE_NEG(SIZE_NEG)
    ) dut (
        .clk(clk), .rstn(rstn), .en(en),
        .pos0_0(pos0_0), .pos0_1(pos0_1), .pos1_0(pos1_0), .pos1_1(pos1_1),
        .neg0_0(neg0_0), .neg0_1(neg0_1), .neg1_0(neg1_0), .neg1_1(neg1_1),
        .valid_out(valid_out), .sign(sign), .out(out)
    );

    always #10 clk = ~clk;
    
    integer pos1vec1, pos1vec2, pos2vec1, pos2vec2, pos3vec1, pos3vec2;
    integer neg1vec1, neg1vec2, neg2vec1, neg2vec2;
    integer i;
    initial begin
        clk = 1'b1;     rstn = 1'b0;    en = 1'b0;
        repeat(2) @(posedge clk);

        pos1vec1 = 8'b0000_0000; pos1vec2 = 8'b0000_0000;
        pos2vec1 = 8'b0000_0000; pos2vec2 = 8'b0000_0000;
        pos3vec1 = 8'b0000_0000; pos3vec2 = 8'b0000_0000;
        neg1vec1 = 8'b0000_0000; neg1vec2 = 8'b0000_0000;
        neg2vec1 = 8'b0000_0000; neg2vec2 = 8'b0000_0000;
        for (i=0; i<SIZE_BLOCK; i=i+1) begin
            pos0_0 = {pos3vec1[2*SIZE_BLOCK-1-i],pos2vec1[2*SIZE_BLOCK-1-i],pos1vec1[2*SIZE_BLOCK-1-i]};
            pos0_1 = {pos3vec2[2*SIZE_BLOCK-1-i],pos2vec2[2*SIZE_BLOCK-1-i],pos1vec2[2*SIZE_BLOCK-1-i]};
            neg0_0 = {neg2vec1[2*SIZE_BLOCK-1-i],neg1vec1[2*SIZE_BLOCK-1-i]};
            neg0_1 = {neg2vec2[2*SIZE_BLOCK-1-i],neg1vec2[2*SIZE_BLOCK-1-i]};

            pos1_0 = {pos3vec1[SIZE_BLOCK-1-i],pos2vec1[SIZE_BLOCK-1-i],pos1vec1[SIZE_BLOCK-1-i]};
            pos1_1 = {pos3vec2[SIZE_BLOCK-1-i],pos2vec2[SIZE_BLOCK-1-i],pos1vec2[SIZE_BLOCK-1-i]};
            neg1_0 = {neg2vec1[SIZE_BLOCK-1-i],neg1vec1[SIZE_BLOCK-1-i]};
            neg1_1 = {neg2vec2[SIZE_BLOCK-1-i],neg1vec2[SIZE_BLOCK-1-i]};
            @(posedge clk); rstn=1'b1; en=1'b1;
        end

        pos1vec1 = 8'b0000_0000; pos1vec2 = 8'b0000_0000;
        pos2vec1 = 8'b0000_0000; pos2vec2 = 8'b0000_0000;
        pos3vec1 = 8'b0000_0000; pos3vec2 = 8'b0000_0000;
        neg1vec1 = 8'b0000_0000; neg1vec2 = 8'b0000_0000;
        neg2vec1 = 8'b0000_0000; neg2vec2 = 8'b0000_0000;
        for (i=0; i<SIZE_BLOCK; i=i+1) begin
            pos0_0 = {pos3vec1[2*SIZE_BLOCK-1-i],pos2vec1[2*SIZE_BLOCK-1-i],pos1vec1[2*SIZE_BLOCK-1-i]};
            pos0_1 = {pos3vec2[2*SIZE_BLOCK-1-i],pos2vec2[2*SIZE_BLOCK-1-i],pos1vec2[2*SIZE_BLOCK-1-i]};
            neg0_0 = {neg2vec1[2*SIZE_BLOCK-1-i],neg1vec1[2*SIZE_BLOCK-1-i]};
            neg0_1 = {neg2vec2[2*SIZE_BLOCK-1-i],neg1vec2[2*SIZE_BLOCK-1-i]};

            pos1_0 = {pos3vec1[SIZE_BLOCK-1-i],pos2vec1[SIZE_BLOCK-1-i],pos1vec1[SIZE_BLOCK-1-i]};
            pos1_1 = {pos3vec2[SIZE_BLOCK-1-i],pos2vec2[SIZE_BLOCK-1-i],pos1vec2[SIZE_BLOCK-1-i]};
            neg1_0 = {neg2vec1[SIZE_BLOCK-1-i],neg1vec1[SIZE_BLOCK-1-i]};
            neg1_1 = {neg2vec2[SIZE_BLOCK-1-i],neg1vec2[SIZE_BLOCK-1-i]};
            @(posedge clk); rstn=1'b1; en=1'b1;
        end
        repeat(5) @(posedge clk); rstn=1'b0; en=1'b0;
        `ifdef OUR
        $display("OUR Scheme Design is enabled!");
        `else
        $display("OUR Scheme Design is disabled!");
        `endif
        #100 $finish;
    end
endmodule