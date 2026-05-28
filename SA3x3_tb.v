`timescale 1ns / 1ps

module tb_SA3x3;
    reg clk, rst;
    reg [127:0] flat_image;
    reg [71:0]  flat_kernel;

    wire pe_clr;
    wire [7:0] r_din0, r_din1, r_din2;
    wire [7:0] w00, w01, w02, w10, w11, w12, w20, w21, w22;
    wire [7:0] sout20, sout21, sout22;
    wire [7:0] c11_3x3, c12_3x3, c21_3x3, c22_3x3;
    wire done;

    SA3x3_CTRL u_fsm (
        .clk(clk), .rst(rst),
        .flat_image(flat_image), .flat_kernel(flat_kernel),
        .sout20(sout20), .sout21(sout21), .sout22(sout22),
        .pe_clr(pe_clr),
        .r_din0(r_din0), .r_din1(r_din1), .r_din2(r_din2),
        .w00(w00), .w01(w01), .w02(w02),
        .w10(w10), .w11(w11), .w12(w12),
        .w20(w20), .w21(w21), .w22(w22),
        .c11_3x3(c11_3x3), .c12_3x3(c12_3x3),
        .c21_3x3(c21_3x3), .c22_3x3(c22_3x3),
        .done(done)
    );

    SA3x3 u_array (
        .clk(clk), .rst(rst), .clear(pe_clr),
        .din0(r_din0), .din1(r_din1), .din2(r_din2),
        .win00(w00), .win01(w01), .win02(w02),
        .win10(w10), .win11(w11), .win12(w12),
        .win20(w20), .win21(w21), .win22(w22),
        .out20(sout20), .out21(sout21), .out22(sout22)
    );

    always #5 clk = ~clk;

    integer fail_count;

    task check4;
        input [7:0] e11, e12, e21, e22;
        input integer tc;
        begin
            if (c11_3x3===e11 && c12_3x3===e12 && c21_3x3===e21 && c22_3x3===e22) begin
                $display("TC%0d >>> PASS  C11=%0d C12=%0d C21=%0d C22=%0d",
                         tc, e11, e12, e21, e22);
            end else begin
                $display("TC%0d >>> FAIL", tc);
                $display("  Expected C11=%0d C12=%0d C21=%0d C22=%0d", e11, e12, e21, e22);
                $display("  Got      C11=%0d C12=%0d C21=%0d C22=%0d",
                         c11_3x3, c12_3x3, c21_3x3, c22_3x3);
                fail_count = fail_count + 1;
            end
        end
    endtask

    task run_test;
        input [127:0] img;
        input [71:0]  ker;
        begin
            rst = 0; #10; rst = 1;
            flat_image  = img;
            flat_kernel = ker;
            wait(done);
            #10;
        end
    endtask

    initial begin
        clk = 0; rst = 1;
        flat_image = 0; flat_kernel = 0;
        fail_count = 0;
        #20;

        $display("=================================");
        $display(" 3x3 Systolic Array Testbench");
        $display("=================================");

        // -------------------------------------------------
        // TC1: 체커보드 + 순차 커널 (1~9)
        // C11=25, C12=20, C21=20, C22=25
        // -------------------------------------------------
        run_test(
            {8'd1,8'd0,8'd1,8'd0, 8'd0,8'd1,8'd0,8'd1,
             8'd1,8'd0,8'd1,8'd0, 8'd0,8'd1,8'd0,8'd1},
            {8'd1,8'd2,8'd3, 8'd4,8'd5,8'd6, 8'd7,8'd8,8'd9}
        );
        check4(8'd25, 8'd20, 8'd20, 8'd25, 1);

        // -------------------------------------------------
        // TC2: 순차 이미지 (1~16) + 전부 1인 커널
        // C11=54, C12=63, C21=90, C22=99
        // -------------------------------------------------
        run_test(
            {8'd1, 8'd2, 8'd3, 8'd4,
             8'd5, 8'd6, 8'd7, 8'd8,
             8'd9, 8'd10,8'd11,8'd12,
             8'd13,8'd14,8'd15,8'd16},
            {9{8'd1}}
        );
        check4(8'd54, 8'd63, 8'd90, 8'd99, 2);

        // -------------------------------------------------
        // TC3: 순차 이미지 + identity 커널
        // C11=6, C12=7, C21=10, C22=11
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
