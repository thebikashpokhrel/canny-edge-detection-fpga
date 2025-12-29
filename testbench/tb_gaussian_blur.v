`timescale 1ns/1ps

module tb_gaussian_blur;

    reg clk = 0;
    reg rst = 1;

    reg [7:0] img [0:257][0:257]; //256*256 image with zero padding
    reg [7:0] img_flat [0:65535];
    reg[7:0] p00, p01, p02;
    reg[7:0] p10, p11, p12;
    reg[7:0] p20, p21, p22;

    wire [7:0] out;

    integer x,y;
    integer out_file;

    gaussian_blur uut (
        .clk(clk),
        .rst(rst),
        .p00(p00), .p01(p01), .p02(p02),
        .p10(p10), .p11(p11), .p12(p12),
        .p20(p20), .p21(p21), .p22(p22),
        .out(out)
    );

    always #5 clk = ~clk;

    initial begin
        $readmemh("data/input_image.txt", img_flat);
        out_file = $fopen("data/output_image.txt", "w");

        #20;
        rst = 0;

        //1d array to 2d with zero padding at boundaries
        for (y = 0; y < 258; y = y+1)
            for (x = 0; x < 258; x = x+1)
             if( x == 0 || x == 257 || y == 0 || y == 257)
                img[y][x] = 0;
             else
                img[y][x] = img_flat[(y-1)*256+(x-1)];
        
        //apply filter to each pixel
        for (y = 1; y < 257; y = y+1) begin
            for (x = 1; x< 257; x = x+1) begin
                p00 = img[y-1][x-1]; p01 = img[y-1][x]; p02 = img[y-1][x+1];
                p10 = img[y][x-1]; p11 = img[y][x]; p12 = img[y][x+1];
                p20 = img[y+1][x-1]; p21 = img[y+1][x]; p22 = img[y+1][x+1];

                #10
                $fwrite(out_file, "%h\n", out);
            end
        end

        $fclose(out_file);
        $finish;
    end
endmodule
