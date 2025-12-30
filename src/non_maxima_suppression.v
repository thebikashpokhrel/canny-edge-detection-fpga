module non_maxima_suppression(
    input clk,
    input rst,

    input [7:0] p00, p01, p02,
    input [7:0] p10, p11, p12,
    input [7:0] p20, p21, p22,
    input grad_dir,
    output reg[7:0] edge_out
);
    reg [7:0] grad_center;
    reg [7:0] neighbor1;
    reg [7:0] neighbor2;

    always @(*) begin
        grad_center = p11;

        if (grad_dir == 0) begin
            neighbor1 = p10;
            neighbor2 = p21;
        end
        else begin
            neighbor1 = p01;
            neighbor2 = p21;
        end

        if((grad_center >= neighbor1) && (grad_center >= neighbor2))
            edge_out = grad_center;
        else
            edge_out = 0;
    end
endmodule