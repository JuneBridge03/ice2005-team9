`timescale 1ns/1ns

module display_tb(
    );

    reg clk, rst;
    reg [7:0] sa_2x2_11, sa_2x2_12, sa_2x2_21, sa_2x2_22;
    reg [7:0] sa_3x3_11, sa_3x3_12, sa_3x3_21, sa_3x3_22;

    //출력
    wire [7:0] display_data;
    wire [6:0] seg_led;
    wire [2:0] seg_digit;


    display_module #(.FSM_MAX(100), .DRIVER_MAX(10)) display (
        .sa_2x2_11(sa_2x2_11), .sa_2x2_12(sa_2x2_12), .sa_2x2_21(sa_2x2_21), .sa_2x2_22(sa_2x2_22),
        .sa_3x3_11(sa_3x3_11), .sa_3x3_12(sa_3x3_12), .sa_3x3_21(sa_3x3_21), .sa_3x3_22(sa_3x3_22),
        .clk(clk), .rst(rst),
        .display_data(display_data), .seg_led(seg_led), .seg_digit(seg_digit));

    //클럭(100MHz)
    always #5 clk = ~clk;

    //Stimulus
    initial begin
        clk = 0;
        rst = 1;

        sa_3x3_11 = 8'd50; sa_3x3_12 = 8'd60; sa_3x3_21 = 8'd70; sa_3x3_22 = 8'd80;
        sa_2x2_11 = 8'd90; sa_2x2_12 = 8'd100; sa_2x2_21 = 8'd110; sa_2x2_22 = 8'd120;

        #20 rst = 0;

        #15000 rst = 1;
    end

endmodule
