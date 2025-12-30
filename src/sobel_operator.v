module sobel_operator(
    input clk,
    input rst,
    input [7:0] p00, p01, p02,
    input [7:0] p10, p11, p12,
    input [7:0] p20, p21, p22,
    output reg [7:0] grad_mag,
    output reg grad_dir
);

    reg signed [11:0] gx;
    reg signed [11:0] gy;

    reg [11:0] mag_gx, mag_gy;

    always @(*) begin
        //sobel x kernel
        // -1 0 1
        // -2 0 2
        // -1 0 1
        gx = -p00 - (p10 << 1) - p20 + p02 + (p12 << 1) + p22;
        //sobel y kernel
        // 1 2 1
        // 0 0 0
        // -1 -2 -1
        gy = p00 + (p01 << 1) + p02 - p20 - (p21 << 1) - p22;
    end

    always @(*) begin
        mag_gx = (gx < 0) ? -gx: gx;
        mag_gy = (gy < 0) ? -gy: gy;
    end

    always @(posedge clk) begin
        if(rst) begin
            grad_mag = 0;
            grad_dir = 0;
        end
        else begin
            grad_mag <= (mag_gx + mag_gy) > 255 ? 8'hFF : mag_gx + mag_gy;

            if (mag_gx > mag_gy)
                grad_dir <= 1'b0;
            else
                grad_dir <= 1'b1;
        end
    end
endmodule