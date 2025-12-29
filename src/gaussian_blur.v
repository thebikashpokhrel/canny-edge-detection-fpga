module gaussian_blur(
    input clk,
    input rst,
    input [7:0] p00, p01, p02,
    input [7:0] p10, p11, p12,
    input [7:0] p20, p21, p22,
    output reg [7:0] out
);

    reg [11:0] sum;
    // the gaussian kernel is 
    // 1 2 1
    // 2 4 2
    // 1 2 1
    // normalized by dividing by 16

    always @(*) begin
        sum = p00 + (p01 << 1) + p02 + (p10<<1) + (p11 << 2) + (p12 << 1) + p20 + (p21 << 1) + p22;
    end

    always @(posedge clk) begin
        if(rst)
            out <= 0;
        else
            out <= sum >> 4; // normalized by 16
    end
endmodule
    