`timescale 1ns / 1ps

module tb_timing;
    reg clk, rst;
    reg [127:0] flat_image;
    reg [71:0]  flat_kernel;

    wire [7:0] c11_pe,  c12_pe,  c21_pe,  c22_pe;
    wire [7:0] c11_2x2, c12_2x2, c21_2x2, c22_2x2;
    wire [7:0] c11_3x3, c12_3x3, c21_3x3, c22_3x3;
    wire done_pe, done_2x2, done_3x3;

    Block_SinglePE u_pe (
        .clk(clk), .rst(rst),
        .flat_image(flat_image), .flat_kernel(flat_kernel),
        .c11_pe(c11_pe), .c12_pe(c12_pe), .c21_pe(c21_pe), .c22_pe(c22_pe),
        .done(done_pe)
    );

    Block_Array2x2 u_2x2 (
        .clk(clk), .rst(rst),
        .flat_image(flat_image), .flat_kernel(flat_kernel),
        .c11_2x2(c11_2x2), .c12_2x2(c12_2x2), .c21_2x2(c21_2x2), .c22_2x2(c22_2x2),
        .done(done_2x2)
    );

    Block_Array3x3 u_3x3 (
        .clk(clk), .rst(rst),
        .flat_image(flat_image), .flat_kernel(flat_kernel),
        .c11_3x3(c11_3x3), .c12_3x3(c12_3x3), .c21_3x3(c21_3x3), .c22_3x3(c22_3x3),
        .done(done_3x3)
    );

    always #5 clk = ~clk;

    integer t_start, t_end_pe, t_end_2x2, t_end_3x3;

    initial begin
        clk = 0; rst = 0;
        flat_image = 0; flat_kernel = 0;
        #20;

        // TC: Sequential 1-16 image + All-1s kernel
        // Expected: C11=54, C12=63, C21=90, C22=99
        rst = 1;
        #10;
        rst = 0;
        flat_image  = {8'd1,  8'd2,  8'd3,  8'd4,
                       8'd5,  8'd6,  8'd7,  8'd8,
                       8'd9,  8'd10, 8'd11, 8'd12,
                       8'd13, 8'd14, 8'd15, 8'd16};
        flat_kernel = {9{8'd1}};

        // rst 해제 직후 첫 posedge가 computation start
        @(posedge clk);
        t_start = $time;

        fork
            begin @(posedge done_pe);  t_end_pe  = $time; end
            begin @(posedge done_2x2); t_end_2x2 = $time; end
            begin @(posedge done_3x3); t_end_3x3 = $time; end
        join

        $display("=================================================");
        $display(" Performance Timing Measurement");
        $display("=================================================");
        $display("Computation start : %0d ns", t_start);
        $display("-------------------------------------------------");
        $display("Single PE   : done at %0d ns  =>  %0d clock cycles",
                 t_end_pe,  (t_end_pe  - t_start) / 10);
        $display("SA 2x2      : done at %0d ns  =>  %0d clock cycles",
                 t_end_2x2, (t_end_2x2 - t_start) / 10);
        $display("SA 3x3      : done at %0d ns  =>  %0d clock cycles",
                 t_end_3x3, (t_end_3x3 - t_start) / 10);
        $display("-------------------------------------------------");
        $display("Speedup SA2x2 vs PE : %0d / %0d = %.2f x",
                 (t_end_pe - t_start) / 10,
                 (t_end_2x2 - t_start) / 10,
                 $itor(t_end_pe - t_start) / $itor(t_end_2x2 - t_start));
        $display("Speedup SA3x3 vs PE : %0d / %0d = %.2f x",
                 (t_end_pe - t_start) / 10,
                 (t_end_3x3 - t_start) / 10,
                 $itor(t_end_pe - t_start) / $itor(t_end_3x3 - t_start));
        $display("=================================================");
        $finish;
    end
endmodule
