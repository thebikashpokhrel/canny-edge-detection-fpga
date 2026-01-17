`timescale 1ns / 1ps
module canny_edge(
    input axi_clk,
    input axi_rst_n,
    //slave
    input pixel_in_valid,
    input [7:0] pixel_in,
    output pixel_out_ready,
    //master
    output pixel_out_valid,
    output [7:0] pixel_out,
    input pixel_in_ready,
    //interrupt signal
    output interrupt
);
    
    wire rst = !axi_rst_n;
    wire axis_prog_full;
    assign pixel_out_ready = !axis_prog_full;

    //Gaussian Blur
    wire [71:0] gauss_window;
    wire gauss_valid;
    wire gauss_intr;
    
    controller CT_GAUSS(
        .clk(axi_clk), .rst(rst),
        .pixel_in(pixel_in), .pixel_in_valid(pixel_in_valid),
        .pixel_out(gauss_window), .pixel_out_valid(gauss_valid),
        .out_intr(gauss_intr)
    );
    
    assign interrupt = gauss_intr; 

    wire [7:0] blurred_pixel;
    wire blurred_valid;
    gaussian_blur GB(
        .clk(axi_clk), .rst(rst),
        .pixels_in(gauss_window), .pixels_in_valid(gauss_valid),
        .out_valid(blurred_valid), .out(blurred_pixel)
    );

    // Sobel Operator
    wire [71:0] sobel_window;
    wire sobel_valid;

    controller CT_SOBEL(
        .clk(axi_clk), .rst(rst),
        .pixel_in(blurred_pixel), .pixel_in_valid(blurred_valid),
        .pixel_out(sobel_window), .pixel_out_valid(sobel_valid),
        .out_intr()
    );

    wire [7:0] grad_mag;
    wire [1:0] grad_dir; 
    wire sobel_out_valid;

    sobel_operator SO(
        .clk(axi_clk), .rst(rst),
        .p00(sobel_window[71:64]), .p01(sobel_window[63:56]), .p02(sobel_window[55:48]),
        .p10(sobel_window[47:40]), .p11(sobel_window[39:32]), .p12(sobel_window[31:24]),
        .p20(sobel_window[23:16]), .p21(sobel_window[15:8]),  .p22(sobel_window[7:0]),
        .pixel_in_valid(sobel_valid),
        .grad_mag(grad_mag),
        .grad_dir(grad_dir),
        .pixel_out_valid(sobel_out_valid)
    );

    // Non-Maxima Suppression
    wire [71:0] nms_mag_window;
    wire nms_mag_valid;

    controller CT_NMS_MAG(
        .clk(axi_clk), .rst(rst),
        .pixel_in(grad_mag), .pixel_in_valid(sobel_out_valid),
        .pixel_out(nms_mag_window), .pixel_out_valid(nms_mag_valid),
        .out_intr()
    );

    wire [71:0] nms_dir_window;
    controller CT_NMS_DIR(
        .clk(axi_clk), .rst(rst),
        .pixel_in({6'b0, grad_dir}), .pixel_in_valid(sobel_out_valid),
        .pixel_out(nms_dir_window), .pixel_out_valid(), 
        .out_intr()
    );

    wire [1:0] center_dir = nms_dir_window[33:32]; 
    wire [7:0] nms_out;
    wire nms_out_valid;

    non_maxima_suppression NMS(
        .clk(axi_clk), .rst(rst),
        .p00(nms_mag_window[71:64]), .p01(nms_mag_window[63:56]), .p02(nms_mag_window[55:48]),
        .p10(nms_mag_window[47:40]), .p11(nms_mag_window[39:32]), .p12(nms_mag_window[31:24]),
        .p20(nms_mag_window[23:16]), .p21(nms_mag_window[15:8]),  .p22(nms_mag_window[7:0]),
        .grad_dir(center_dir),
        .pixel_in_valid(nms_mag_valid),
        .edge_out(nms_out),
        .pixel_out_valid(nms_out_valid)
    );

    // Hysteresis Thresholding
    wire [71:0] hyst_window;
    wire hyst_in_valid;

    controller CT_HYST(
        .clk(axi_clk), .rst(rst),
        .pixel_in(nms_out), .pixel_in_valid(nms_out_valid),
        .pixel_out(hyst_window), .pixel_out_valid(hyst_in_valid),
        .out_intr()
    );

    wire [7:0] final_edge_out;
    wire final_valid;

    hysteresis HYST(
        .clk(axi_clk), .rst(rst),
        .p00(hyst_window[71:64]), .p01(hyst_window[63:56]), .p02(hyst_window[55:48]),
        .p10(hyst_window[47:40]), .p11(hyst_window[39:32]), .p12(hyst_window[31:24]),
        .p20(hyst_window[23:16]), .p21(hyst_window[15:8]),  .p22(hyst_window[7:0]),
        .in_valid(hyst_in_valid),
        .out(final_edge_out),
        .out_valid(final_valid)
    );

    // Output FIFO
    fifo_generator_0 OB (
      .s_aclk(axi_clk), .s_aresetn(axi_rst_n),
      .s_axis_tvalid(final_valid),
      .s_axis_tready(),
      .s_axis_tdata(final_edge_out),
      .m_axis_tvalid(pixel_out_valid),
      .m_axis_tready(pixel_in_ready),
      .m_axis_tdata(pixel_out),
      .axis_prog_full(axis_prog_full)
    );

endmodule