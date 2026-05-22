`timescale 1ns/1ns

module display_tb(
    );

    //입력은 사전에 선언된 localparam 사용, 별도 wire 지정 안함 - 클럭과 리셋만 지정
    reg clk, rst;
    reg [7:0] pe_11, pe_12, pe_21, pe_22;
    reg [7:0] sa_2x2_11, sa_2x2_12, sa_2x2_21, sa_2x2_22;
    reg [7:0] sa_3x3_11, sa_3x3_12, sa_3x3_21, sa_3x3_22;

    //출력
    wire [7:0] display_data;
    wire [6:0] seg_led;
    wire [2:0] seg_digit;


    display_FSM_module #(.fsm_cnt_max(100)) display_fsm (.pe_11(pe_11), .pe_12(pe_12), .pe_21(pe_21), .pe_22(pe_22),
        .sa_2x2_11(sa_2x2_11), .sa_2x2_12(sa_2x2_12), .sa_2x2_21(sa_2x2_21), .sa_2x2_22(sa_2x2_22),
        .sa_3x3_11(sa_3x3_11), .sa_3x3_12(sa_3x3_12), .sa_3x3_21(sa_3x3_21), .sa_3x3_22(sa_3x3_22),
        .clk(clk),
        .rst(rst),
        .display_data(display_data));

    display_driver_module #(.driver_cnt_max(10)) display_driver (.in(display_data), .clk(clk), .rst(rst), .seg_led(seg_led), .seg_digit(seg_digit));

    //클럭(100MHz)
    always #5 clk = ~clk;

    //Stimulus
    initial begin
        clk = 0;
        rst = 1;

        pe_11 = 8'd10;     pe_12 = 8'd20;     pe_21 = 8'd30;     pe_22 = 8'd40;
        sa_2x2_11 = 8'd50; sa_2x2_12 = 8'd60; sa_2x2_21 = 8'd70; sa_2x2_22 = 8'd80;
        sa_3x3_11 = 8'd90; sa_3x3_12 = 8'd100; sa_3x3_21 = 8'd110; sa_3x3_22 = 8'd120;

        #20 rst = 0;

        #15000 rst = 1;
    end

endmodule
