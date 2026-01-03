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

wire [7:0] pixel_data;
wire pixel_data_valid;
wire axis_prog_full;
wire [7:0] gb_out;
wire gb_out_valid;

assign pixel_out_ready = !axis_prog_full;

controller IC(
    .clk(axi_clk),
    .rst(!axi_rst_n),
    .pixel_in(pixel_in),
    .pixel_in_valid(pixel_in_valid),
    .pixel_out(pixel_data),
    .pixel_out_valid(pixel_data_valid),
    .out_intr(interrupt)
);

gaussian_blur GB(
    .clk(axi_clk),
    .rst(!axi_rst_n),
    .pixels_in(pixel_data),
    .pixels_in_valid(pixel_data_valid),
    .out_valid(gb_out_valid),
    .out(gb_out)
);

//FIFO buffer IP

output_buffer OB (
  .s_aclk(axi_clk),                  // input wire s_aclk
  .s_aresetn(axi_rst_n),            // input wire s_aresetn
  .s_axis_tvalid(gb_out_valid),    // input wire s_axis_tvalid
  .s_axis_tready(),    // output wire s_axis_tready
  .s_axis_tdata(gb_out),      // input wire [7 : 0] s_axis_tdata
  .m_axis_tvalid(pixel_out_valid),    // output wire m_axis_tvalid
  .m_axis_tready(pixel_out_ready),    // input wire m_axis_tready
  .m_axis_tdata(pixel_out),      // output wire [7 : 0] m_axis_tdata
  .axis_prog_full(axis_prog_full)  // output wire axis_prog_full
);

endmodule