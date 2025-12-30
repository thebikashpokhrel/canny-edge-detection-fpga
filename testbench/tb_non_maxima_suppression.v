`timescale 1ns/1ps

module tb_non_maxima_suppression;
    reg clk = 0;
    reg rst = 1;

    reg [7:0] grad_mag_img [0:257][0:257]; // sobel magnitude 2darray 
    reg [7:0] grad_mag_flat [0:65535];

    reg [7:0] p00,p01,p02,p10,p11,p12,p20,p21,p22;
    reg grad_dir_img [0:257][0:257];    
    reg grad_dir_img_flat [0:65535]; 
    
    reg grad_dir;

    wire [7:0] edge_out;

    integer x, y;
    integer in_mag_file, in_dir_file, out_file;

    non_maxima_suppression nms(
        .clk(clk),
        .rst(rst),
        .p00(p00), .p01(p01), .p02(p02),
        .p10(p10), .p11(p11), .p12(p12),
        .p20(p20), .p21(p21), .p22(p22),
        .grad_dir(grad_dir),
        .edge_out(edge_out)
    );

    always #5 clk = ~clk;

    initial begin
        $readmemh("data/output_sobel_grad.txt", grad_mag_flat);
        $readmemb("data/output_sobel_dir.txt", grad_dir_img_flat);

        out_file = $fopen("data/output_nms.txt","w");

        #20;
        rst = 0;

        for (y=0; y<258; y=y+1) begin
            for (x=0; x<258; x=x+1) begin
                if (x==0 || x==257 || y==0 || y==257) begin
                    grad_mag_img[y][x] = 0;
                    grad_dir_img[y][x] = 0;
                end else begin
                    grad_mag_img[y][x] = grad_mag_flat[(y-1)*256 + (x-1)];
                    grad_dir_img[y][x] = grad_dir_img_flat[(y-1)*256 + (x-1)];
                end
            end
        end

        for (y=1; y<257; y=y+1) begin
            for (x=1; x<257; x=x+1) begin
                p00 = grad_mag_img[y-1][x-1]; p01 = grad_mag_img[y-1][x]; p02 = grad_mag_img[y-1][x+1];
                p10 = grad_mag_img[y][x-1];   p11 = grad_mag_img[y][x];   p12 = grad_mag_img[y][x+1];
                p20 = grad_mag_img[y+1][x-1]; p21 = grad_mag_img[y+1][x]; p22 = grad_mag_img[y+1][x+1];

                grad_dir = grad_dir_img[y][x];

                #10
                $fwrite(out_file, "%h\n", edge_out);
            end
        end

        $fclose(out_file);
        $finish;
    end

endmodule
