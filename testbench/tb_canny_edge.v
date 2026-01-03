`timescale 1ns / 1ps

`define image_size 256*256
module tb(

    );
   reg clk;
   reg reset;
   reg [7:0] img_flat [0:65535];
   reg [7:0] img_data;
   reg image_data_valid;
   integer i;
   integer out_file;
   integer sent_size;
   wire intr;
   wire pixel_out_valid;
   wire [7:0] pixel_out;
   integer rx_data =0;
   
   initial begin
    clk = 1'b0;
    forever begin
        #5 clk = ~clk;
    end
   end
    
    initial begin
        reset = 0;
        image_data_valid = 1'b0;
        sent_size = 0;
        #100;
        reset =1;
        #100;
        
        $readmemh("input_image.txt", img_flat);
        out_file = $fopen("output_image.txt", "w");

        for (i=0;i<4*256;i=i+1) begin
            @(posedge clk);
            img_data <= img_flat[i];
            image_data_valid <= 1'b1;
        end

        sent_size = 4*256;

        @(posedge clk);
        image_data_valid <= 1'b0;
        while (sent_size < `image_size) begin
            @(posedge intr);
            for (i=0;i<4*256;i=i+1) begin
                @(posedge clk);
                img_data <= img_flat[sent_size + i];
                image_data_valid <= 1'b1;
            end

            @(posedge clk);
            image_data_valid <= 1'b0;
            sent_size = sent_size + 4*256;
        end

        @(posedge clk);
        image_data_valid <= 1'b0;
        @(posedge intr);
        for (i=0;i<4*256;i=i+1) begin
            @(posedge clk);
            img_data <= 0;
            image_data_valid <= 1'b1;
        end

        @(posedge clk);
        image_data_valid <= 1'b0;
        @(posedge intr);
        for (i=0;i<4*256;i=i+1) begin
            @(posedge clk);
            img_data <= 0;
            image_data_valid <= 1'b1;
        end

        @(posedge clk);
        image_data_valid <= 1'b0;
    end

    always @(posedge clk) begin
        if (pixel_out_valid) begin
            $fwrite(out_file, "%h\n", pixel_out);
            rx_data = rx_data + 1;
        end

        if(rx_data == `image_size) begin
            $fclose(out_file);
            $stop;
        end
    end
    
canny_edge dut(
    .axi_clk(clk),
    .axi_rst_n(reset),
    //slave
    .pixel_in_valid(image_data_valid),
    .pixel_in(img_data),
    .pixel_out_ready(1'b1),
    //master
    .pixel_out_valid(pixel_out_valid),
    .pixel_out(pixel_out),
    .pixel_in_ready(),
    //interrupt signal
    .interrupt(intr)
);

endmodule
