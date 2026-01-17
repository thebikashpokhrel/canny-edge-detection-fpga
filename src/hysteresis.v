`timescale 1ns / 1ps
module hysteresis(
    input clk,
    input rst,
    input [7:0] p00, p01, p02,
    input [7:0] p10, p11, p12,
    input [7:0] p20, p21, p22,
    input in_valid,
    output reg [7:0] out,
    output reg out_valid
);

    parameter [7:0] HIGH_THRESH = 80; 
    parameter [7:0] LOW_THRESH  = 20;

    reg is_strong_edge;
    reg is_weak_edge;
    reg has_strong_neighbor;
    reg stage1_valid;

    // Stage 1: Analyze Center and Neighbors
    always @(posedge clk) begin
        if(rst) begin
            is_strong_edge <= 0;
            is_weak_edge <= 0;
            has_strong_neighbor <= 0;
            stage1_valid <= 0;
        end else begin
            // 1. Check if Center is Strong or Weak
            if (p11 >= HIGH_THRESH) begin
                is_strong_edge <= 1;
                is_weak_edge <= 0;
            end else if (p11 >= LOW_THRESH) begin
                is_strong_edge <= 0;
                is_weak_edge <= 1;
            end else begin
                is_strong_edge <= 0;
                is_weak_edge <= 0;
            end

            // 2. Check if ANY neighbor is Strong
            // (If a neighbor is > HIGH_THRESH, it can "save" a weak center pixel)
            if ((p00 >= HIGH_THRESH) || (p01 >= HIGH_THRESH) || (p02 >= HIGH_THRESH) ||
                (p10 >= HIGH_THRESH) ||                         (p12 >= HIGH_THRESH) ||
                (p20 >= HIGH_THRESH) || (p21 >= HIGH_THRESH) || (p22 >= HIGH_THRESH)) 
            begin
                has_strong_neighbor <= 1;
            end else begin
                has_strong_neighbor <= 0;
            end

            stage1_valid <= in_valid;
        end
    end

    // Stage 2: Final Decision
    always @(posedge clk) begin
        if(rst) begin
            out <= 0;
            out_valid <= 0;
        end else begin
            // 1. If Strong -> Keep it (255)
            // 2. If Weak AND has Strong Neighbor -> Keep it (255)
            // 3. Otherwise -> Kill it (0)
            
            if (is_strong_edge)
                out <= 255;
            else if (is_weak_edge && has_strong_neighbor)
                out <= 255;
            else
                out <= 0;

            out_valid <= stage1_valid;
        end
    end

endmodule