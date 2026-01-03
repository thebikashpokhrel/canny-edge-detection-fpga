module controller(
    input clk,
    input rst,
    input [7:0] pixel_in,
    input pixel_in_valid,
    output [71:0] pixel_out,
    output pixel_out_valid,
    output reg out_intr
);

    reg [7:0] pixel_counter;
    reg [2:0] current_write_lb;
    reg [3:0] lb_data_valid;
    reg [3:0] lb_read_data;
    reg [1:0] current_read_lb;
    reg [23:0] lb0_pixels_out, lb1_pixels_out, lb2_pixels_out, lb3_pixels_out;
    reg [7:0] read_counter;
    reg read_lb;
    reg [9:0] total_pixels_counter;
    reg rd_state;

    localparam IDLE = 1'b0;
    localparam READ = 1'b1;

    assign pixel_out_valid = read_lb;

    always @(posedge clk) begin
        if(rst) 
            total_pixels_counter <= 0;
        else begin
            if(pixel_in_valid & !read_lb)
                total_pixels_counter <= total_pixels_counter + 1;
            else if (!pixel_in_valid & read_lb)
                total_pixels_counter <= total_pixels_counter - 1;
        end
    end

    always @(posedge clk) begin
        if(rst) begin
            rd_state <= IDLE;
            read_lb <= 1'b0;
            out_intr <= 1'b1;
        end else begin
            case (rd_state)
                IDLE: begin
                out_intr <= 1'b0;
                    if (total_pixels_counter >= 768) begin
                        read_lb <= 1'b1;
                        rd_state <= READ;
                    end
                end
                READ: begin
                    if (read_counter == 255) begin
                        rd_state <= IDLE;
                        read_lb <= 1'b0;
                        out_intr <= 1'b1;
                    end
                end
            endcase
        end
    end

    always @(posedge clk) begin
        if (rst)
            pixel_counter <= 0;
        else begin
            if(pixel_in_valid)
                pixel_counter <= pixel_counter + 1;
        end
    end

    always @(posedge clk) begin
        if(rst)
            current_write_lb <=0;
        else begin
            if (pixel_counter == 255 & pixel_in_valid)
                current_write_lb <= current_write_lb + 1;
        end
    end

    always @(*) begin
        lb_data_valid = 4'b0000;
        lb_data_valid[current_write_lb] = pixel_in_valid;
    end

    always @(*) begin
        if(rst) 
            read_counter <= 0;
        else begin
            if (lb_read_data)
                read_counter <= read_counter + 1;
        end
    end

    always @(posedge clk) begin
        if(rst)
            current_read_lb <=0;
        else begin
            if (read_counter == 255 & read_lb)
                current_read_lb <= current_read_lb + 1;
        end
    end

    always @(*) begin
        case (current_read_lb)
            0:begin
                pixel_out = {lb2_pixels_out, lb1_pixels_out, lb0_pixels_out};
            end
            1:begin
                pixel_out = {lb3_pixels_out, lb2_pixels_out, lb1_pixels_out};
            end
            2:begin
                pixel_out = {lb0_pixels_out, lb3_pixels_out, lb3_pixels_out};
            end
            3:begin
                pixel_out = {lb1_pixels_out, lb0_pixels_out, lb3_pixels_out};
            end
        endcase
    end

    always @(*) begin
        case(current_read_lb)
            0:begin
                lb_read_data[0] = read_lb;
                lb_read_data[1] = read_lb;
                lb_read_data[2] = read_lb;
                lb_read_data[3] = 1'b0;
            end
            1:begin
                lb_read_data[0] = 1'b0;
                lb_read_data[1] = read_lb;
                lb_read_data[2] = read_lb;
                lb_read_data[3] = read_lb;
            end
            2:begin
                lb_read_data[0] = read_lb;
                lb_read_data[1] = 1'b0;
                lb_read_data[2] = read_lb;
                lb_read_data[3] = read_lb;
            end
            3:begin
                lb_read_data[0] = read_lb;
                lb_read_data[1] = read_lb;
                lb_read_data[2] = 1'b0;
                lb_read_data[3] = read_lb;
            end
        endcase
    end

    line_buffer lb0 (
        .clk(clk),
        .rst(rst),
        .pixel_in(pixel_in),
        .in_data_valid(lb_data_valid[0]),
        .pixels_out(lb0_pixels_out),
        .read_data(lb_read_data[0])
    );

    line_buffer lb1 (
        .clk(clk),
        .rst(rst),
        .pixel_in(pixel_in),
        .in_data_valid(lb_data_valid[1]),
        .pixels_out(lb1_pixels_out),
        .read_data(lb_read_data[1])
    );

    line_buffer lb2 (
        .clk(clk),
        .rst(rst),
        .pixel_in(pixel_in),
        .in_data_valid(lb_data_valid[2]),
        .pixels_out(lb2_pixels_out),
        .read_data(lb_read_data[2])
    );
    
endmodule