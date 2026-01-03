module gaussian_blur(
    input clk,
    input rst,
    input [71:0] pixels_in, // 3x3 pixels
    input pixels_in_valid,
    output reg out_valid,
    output reg [7:0] out
);
    reg [7:0] p00, p01, p02;
    reg [7:0] p10, p11, p12;
    reg [7:0] p20, p21, p22;

    reg [11:0] stage_row_1, stage_row_2, stage_row_3;
    reg [11:0] stage_2;

    reg pixel_valid, stage_1_valid, stage_2_valid;

    //4 stage pipelining

    always @(posedge clk) begin
        if(rst) begin
            p00 <= 0; p01 <= 0; p02 <= 0;
            p10 <= 0; p11 <= 0; p12 <= 0;
            p20 <= 0; p21 <= 0; p22 <= 0;
            pixel_valid <=0;

        end else if(pixels_in_valid) begin
            p00 <= pixels_in[71:64];
            p01 <= pixels_in[63:56];
            p02 <= pixels_in[55:48];
            p10 <= pixels_in[47:40];
            p11 <= pixels_in[39:32];
            p12 <= pixels_in[31:24];
            p20 <= pixels_in[23:16];
            p21 <= pixels_in[15:8];
            p22 <= pixels_in[7:0];
        end
        pixel_valid <= pixels_in_valid;
    end

    // the gaussian kernel is 
    // 1 2 1
    // 2 4 2
    // 1 2 1
    // normalized by dividing by 16

    always @(posedge clk) begin
        if(rst) begin
            stage_row_1 <= 0;
            stage_row_2 <= 0;
            stage_row_3 <= 0;
            stage_1_valid <= 0;
        end
        else begin
            stage_row_1 <= p00 + (p01 << 1) + p02;
            stage_row_2 <= (p10 << 1) + (p11 << 2) + (p12 << 1);
            stage_row_3 <= p20 + (p21 << 1) + p22;
            stage_1_valid <= pixel_valid;
        end
    end

    always @(posedge clk) begin
        if(rst) begin
            stage_2 <= 0;
            stage_2_valid <= 0;
        end
        else begin
            stage_2 <= stage_row_1 + stage_row_2 + stage_row_3;
            stage_2_valid <= stage_1_valid;
        end
    end

    always @(posedge clk) begin
        if(rst) begin
            out <= 0;
            out_valid <=0;
        end
        else begin
            out <= stage_2 >> 4; // normalized by 16
            out_valid <= stage_2_valid;
        end
    end
endmodule
    