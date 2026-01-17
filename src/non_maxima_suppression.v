`timescale 1ns / 1ps
module non_maxima_suppression(
    input clk,
    input rst,
    input [7:0] p00, p01, p02,
    input [7:0] p10, p11, p12,
    input [7:0] p20, p21, p22,
    input [1:0] grad_dir, 
    input pixel_in_valid,
    output reg [7:0] edge_out,
    output reg pixel_out_valid
);
    
    reg [7:0] center_reg;
    reg [7:0] n1_reg, n2_reg;
    reg stage1_valid;

    // Stage 1: Select Neighbors based on 4 Directions
    always @(posedge clk) begin
        if (rst) begin
            center_reg <= 0; n1_reg <= 0; n2_reg <= 0; stage1_valid <= 0;
        end else begin
            center_reg <= p11;
            
            case (grad_dir)
                2'b00: begin // 0 deg Left/Right
                    n1_reg <= p10;
                    n2_reg <= p12;
                end
                2'b01: begin // 45 deg TopRight/BotLeft
                    n1_reg <= p02;
                    n2_reg <= p20; 
                end
                2'b10: begin // 90 deg Up/Down
                    n1_reg <= p01;
                    n2_reg <= p21;
                end
                2'b11: begin // 135 deg TopLeft/BotRight
                    n1_reg <= p00;
                    n2_reg <= p22;
                end
            endcase
            
            stage1_valid <= pixel_in_valid;
        end
    end

    // Stage 2: Compare and Threshold
    always @(posedge clk) begin
        if (rst) begin
            edge_out <= 0;
            pixel_out_valid <= 0;
        end else begin
            if( (center_reg >= n1_reg) && (center_reg >= n2_reg))
                edge_out <= center_reg;
            else
                edge_out <= 0;
                
            pixel_out_valid <= stage1_valid;
        end
    end
endmodule