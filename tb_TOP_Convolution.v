`timescale 1ns / 1ps

module tb_TOP_Convolution;

    reg clk, rst;
    reg [127:0] flat_image;
    reg [71:0]  flat_kernel;

    wire [7:0] c11_pe,  c12_pe,  c21_pe,  c22_pe;
    wire [7:0] c11_2x2, c12_2x2, c21_2x2, c22_2x2;
    wire [7:0] c11_3x3, c12_3x3, c21_3x3, c22_3x3;
    wire done;
    
    // 새롭게 추가된 디스플레이 와이어
    wire [6:0] seg_led;
    wire [2:0] seg_digit;

    TOP_Convolution uut (
        .clk(clk), .rst(rst),
        .flat_image(flat_image), .flat_kernel(flat_kernel),
        .c11_pe(c11_pe),   .c12_pe(c12_pe),   .c21_pe(c21_pe),   .c22_pe(c22_pe),
        .c11_2x2(c11_2x2), .c12_2x2(c12_2x2), .c21_2x2(c21_2x2), .c22_2x2(c22_2x2),
        .c11_3x3(c11_3x3), .c12_3x3(c12_3x3), .c21_3x3(c21_3x3), .c22_3x3(c22_3x3),
        .done(done),
        .seg_led(seg_led),       // 추가 연결
        .seg_digit(seg_digit)    // 추가 연결
    );

    always #5 clk = ~clk;

    integer fail_count;

    // 세 아키텍처 모두 기댓값과 일치하는지 검사
    task check_all;
        input [7:0] e11, e12, e21, e22;
        input integer tc;
        reg pass;
        begin
            pass = (c11_pe===e11 && c12_pe===e12 && c21_pe===e21 && c22_pe===e22) &&
                   (c11_2x2===e11 && c12_2x2===e12 && c21_2x2===e21 && c22_2x2===e22) &&
                   (c11_3x3===e11 && c12_3x3===e12 && c21_3x3===e21 && c22_3x3===e22);
            if (pass) begin
                $display("TC%0d >>> PASS  C11=%0d C12=%0d C21=%0d C22=%0d",
                         tc, e11, e12, e21, e22);
            end else begin
                $display("TC%0d >>> FAIL", tc);
                $display("  Expected : C11=%0d C12=%0d C21=%0d C22=%0d", e11, e12, e21, e22);
                $display("  PE       : C11=%0d C12=%0d C21=%0d C22=%0d",
                         c11_pe,  c12_pe,  c21_pe,  c22_pe);
                $display("  2x2 SA   : C11=%0d C12=%0d C21=%0d C22=%0d",
                         c11_2x2, c12_2x2, c21_2x2, c22_2x2);
                $display("  3x3 SA   : C11=%0d C12=%0d C21=%0d C22=%0d",
                         c11_3x3, c12_3x3, c21_3x3, c22_3x3);
                fail_count = fail_count + 1;
            end
        end
    endtask

    // 리셋 후 입력 인가 → done 대기
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

        $display("=================================================");
        $display(" TOP_Convolution Testbench (PE / 2x2 SA / 3x3 SA)");
        $display("=================================================");

        // -------------------------------------------------
        // TC1: 체커보드 이미지 + 순차 커널 (1~9)
        // -------------------------------------------------
        run_test(
            {8'd1,8'd0,8'd1,8'd0, 8'd0,8'd1,8'd0,8'd1,
             8'd1,8'd0,8'd1,8'd0, 8'd0,8'd1,8'd0,8'd1},
            {8'd1,8'd2,8'd3, 8'd4,8'd5,8'd6, 8'd7,8'd8,8'd9}
        );
        check_all(8'd25, 8'd20, 8'd20, 8'd25, 1);

        // -------------------------------------------------
        // TC2: 순차 이미지 (1~16) + 전부 1인 커널
        // -------------------------------------------------
        run_test(
            {8'd1, 8'd2, 8'd3, 8'd4,
             8'd5, 8'd6, 8'd7, 8'd8,
             8'd9, 8'd10,8'd11,8'd12,
             8'd13,8'd14,8'd15,8'd16},
            {9{8'd1}}
        );
        check_all(8'd54, 8'd63, 8'd90, 8'd99, 2);

        // -------------------------------------------------
        // TC3: 전체 2인 이미지 + 전체 10인 커널
        // -------------------------------------------------
        run_test({16{8'd2}}, {9{8'd10}});
        check_all(8'd180, 8'd180, 8'd180, 8'd180, 3);

        // -------------------------------------------------
        // TC4: 전체 0인 이미지
        // -------------------------------------------------
        run_test({16{8'd0}}, {8'd1,8'd2,8'd3, 8'd4,8'd5,8'd6, 8'd7,8'd8,8'd9});
        check_all(8'd0, 8'd0, 8'd0, 8'd0, 4);

        // -------------------------------------------------
        // TC5: 순차 이미지 + 가운데만 1인 커널 (identity)
        // -------------------------------------------------
        run_test(
            {8'd1, 8'd2, 8'd3, 8'd4,
             8'd5, 8'd6, 8'd7, 8'd8,
             8'd9, 8'd10,8'd11,8'd12,
             8'd13,8'd14,8'd15,8'd16},
            {8'd0,8'd0,8'd0, 8'd0,8'd1,8'd0, 8'd0,8'd0,8'd0}
        );
        check_all(8'd6, 8'd7, 8'd10, 8'd11, 5);

        $display("=================================================");
        if (fail_count == 0)
            $display("ALL %0d TESTS PASSED", 5);
        else
            $display("%0d / 5 TEST(S) FAILED", fail_count);
        $display("=================================================");

        $finish;
    end

endmodule
