module line_buffer(
    input clk,
    input rst,
    input [7:0] pixel_in,
    input in_data_valid,
    output [23:0] pixels_out,
    input read_data
);

    reg [7:0] line [255:0]; //line buffer for 256 pixels
    reg [7:0] write_ptr;
    reg [7:0] read_ptr;

    always @(posedge clk) begin
        if(in_data_valid)
            line[write_ptr] <= pixel_in;
    end

    always @(posedge clk) begin
        if(rst)
            write_ptr <= 'd0;
        else if(in_data_valid)
            write_ptr <= write_ptr + 'd1;
    end

    assign pixels_out = {line[read_ptr], line[(read_ptr + 1) % 256], line[(read_ptr + 2) % 256]};

    always @(posedge clk) begin
        if(rst)
            read_ptr <= 'd0;
        else if(read_data)
            read_ptr <= read_ptr + 'd1;
    end
endmodule