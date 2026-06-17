`timescale 1ns / 1ps

module tb_SA2x2;
    reg clk, rst;
    reg [127:0] flat_image;
    reg [71:0]  flat_kernel;

    wire       pe_clr;
    wire [7:0] f1, f2, i1, i2;
    wire [7:0] po1, po2, po3, po4;
    wire [7:0] c11, c12, c21, c22;
    wire done;

    SA2x2_CTRL u_fsm (
        .clk(clk), .rst(rst),
        .flat_image(flat_image), .flat_kernel(flat_kernel),
        .pe_out_1(po1), .pe_out_2(po2), .pe_out_3(po3), .pe_out_4(po4),
        .pe_clr(pe_clr),
        .systolic_filter_in0(f1), .systolic_filter_in1(f2),
        .systolic_data_in0(i1), .systolic_data_in1(i2),
        .c11(c11), .c12(c12), .c21(c21), .c22(c22),
        .done(done)
    );

    SA2x2 u_array (
        .clk(clk), .rst(rst), .clear(pe_clr),
        .filter1(f1), .filter2(f2), .in1(i1), .in2(i2),
        .pe_out_1(po1), .pe_out_2(po2), .pe_out_3(po3), .pe_out_4(po4)
    );

    always #5 clk = ~clk;

    integer fail_count;

    task check4;
        input [7:0] e11, e12, e21, e22;
        input integer tc;
        begin
            if (c11===e11 && c12===e12 && c21===e21 && c22===e22) begin
                $display("TC%0d >>> PASS  C11=%0d C12=%0d C21=%0d C22=%0d",
                         tc, e11, e12, e21, e22);
            end else begin
                $display("TC%0d >>> FAIL", tc);
                $display("  Expected C11=%0d C12=%0d C21=%0d C22=%0d", e11, e12, e21, e22);
                $display("  Got      C11=%0d C12=%0d C21=%0d C22=%0d", c11, c12, c21, c22);
                fail_count = fail_count + 1;
            end
        end
    endtask

    task run_test;
        input [127:0] img;
        input [71:0]  ker;
        begin
            rst = 1; #10; rst = 0;
            flat_image  = img;
            flat_kernel = ker;
            wait(done);
            #10;
        end
    endtask

    initial begin
        clk = 0; rst = 0;
        flat_image = 0; flat_kernel = 0;
        fail_count = 0;
        #20;

        $display("=================================");
        $display(" 2x2 Systolic Array Testbench");
        $display("=================================");

        // -------------------------------------------------
        // TC1: 순차 이미지 (1~16) + 전부 1인 커널
        // C11=54, C12=63, C21=90, C22=99
        // -------------------------------------------------
        run_test(
            {8'd1, 8'd2, 8'd3, 8'd4,
             8'd5, 8'd6, 8'd7, 8'd8,
             8'd9, 8'd10,8'd11,8'd12,
             8'd13,8'd14,8'd15,8'd16},
            {9{8'd1}}
        );
        check4(8'd54, 8'd63, 8'd90, 8'd99, 1);

        // -------------------------------------------------
        // TC2: 체커보드 + 순차 커널 (1~9)
        // C11=25, C12=20, C21=20, C22=25
        // -------------------------------------------------
        run_test(
            {8'd1,8'd0,8'd1,8'd0, 8'd0,8'd1,8'd0,8'd1,
             8'd1,8'd0,8'd1,8'd0, 8'd0,8'd1,8'd0,8'd1},
            {8'd1,8'd2,8'd3, 8'd4,8'd5,8'd6, 8'd7,8'd8,8'd9}
        );
        check4(8'd25, 8'd20, 8'd20, 8'd25, 2);

        // -------------------------------------------------
        // TC3: 순차 이미지 + identity 커널 (중앙=1, 나머지=0)
        // C11=img[1][1]=6, C12=img[1][2]=7,
        // C21=img[2][1]=10, C22=img[2][2]=11
        // -------------------------------------------------
        run_test(
            {8'd1, 8'd2, 8'd3, 8'd4,
             8'd5, 8'd6, 8'd7, 8'd8,
             8'd9, 8'd10,8'd11,8'd12,
             8'd13,8'd14,8'd15,8'd16},
            {8'd0,8'd0,8'd0, 8'd0,8'd1,8'd0, 8'd0,8'd0,8'd0}
        );
        check4(8'd6, 8'd7, 8'd10, 8'd11, 3);

        // -------------------------------------------------
        // TC4: 전체 0 이미지 → 모든 출력 0
        // -------------------------------------------------
        run_test({16{8'd0}}, {9{8'd1}});
        check4(8'd0, 8'd0, 8'd0, 8'd0, 4);

        // -------------------------------------------------
        // TC5: 전체 균일(3) 이미지 + 전체 균일(5) 커널
        // C** = 9 * 3 * 5 = 135
        // -------------------------------------------------
        run_test({16{8'd3}}, {9{8'd5}});
        check4(8'd135, 8'd135, 8'd135, 8'd135, 5);

        $display("=================================");
        if (fail_count == 0)
            $display("ALL %0d TESTS PASSED", 5);
        else
            $display("%0d / 5 TEST(S) FAILED", fail_count);
        $display("=================================");

        $finish;
    end

endmodule
