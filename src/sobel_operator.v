`timescale 1ns / 1ps
module sobel_operator(
    input clk,
    input rst,
    input [7:0] p00, p01, p02,
    input [7:0] p10, p11, p12,
    input [7:0] p20, p21, p22,
    input pixel_in_valid,
    output reg [7:0] grad_mag,
    output reg [1:0] grad_dir,
    output reg pixel_out_valid
);
    
    reg signed [11:0] gx, gy;
    reg [11:0] abs_gx, abs_gy;
    reg stage1_valid, stage2_valid;

    // Stage 1: calculate Gx and Gy
    always @(posedge clk) begin
        if (rst) begin
            gx <= 0; gy <= 0; stage1_valid <= 0;
        end else begin
            gx <= -p00 - (p10 << 1) - p20 + p02 + (p12 << 1) + p22;
            gy <=  p00 + (p01 << 1) + p02 - p20 - (p21 << 1) - p22;
            stage1_valid <= pixel_in_valid;
        end
    end

    // Stage 2: abs Values
    always @(posedge clk) begin
        if (rst) begin
            abs_gx <= 0; abs_gy <= 0; stage2_valid <= 0;
        end else begin
            abs_gx <= (gx < 0) ? -gx : gx;
            abs_gy <= (gy < 0) ? -gy : gy;
            stage2_valid <= stage1_valid;
        end
    end

    // Stage 3: Magnitude and Direction
    always @(posedge clk) begin
        if(rst) begin
            grad_mag <= 0;
            grad_dir <= 0;
            pixel_out_valid <= 0;
        end
        else begin
            grad_mag <= ((abs_gx + abs_gy) > 255) ? 8'hFF : (abs_gx + abs_gy);

            if (abs_gy <= (abs_gx >> 1)) begin
                grad_dir <= 2'b00;
            end
            else if (abs_gx <= (abs_gy >> 1)) begin
                grad_dir <= 2'b10;
            end
            else begin
                if ((gx[11] == gy[11])) 
                    grad_dir <= 2'b11;
                else
                    grad_dir <= 2'b01; 
            end
                
            pixel_out_valid <= stage2_valid;
        end
    end
endmodule