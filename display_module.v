module display_module #(
    parameter FSM_MAX = 27'd99_999_999,
    parameter DRIVER_MAX = 18'd199999
    )(
    input [7:0] sa_2x2_11,
    input [7:0] sa_2x2_12,
    input [7:0] sa_2x2_21,
    input [7:0] sa_2x2_22,
    input [7:0] sa_3x3_11,
    input [7:0] sa_3x3_12,
    input [7:0] sa_3x3_21,
    input [7:0] sa_3x3_22,
    input clk,
    input rst,

    output [7:0] display_data, //For simulation only
    output [6:0] seg_led,
    output [2:0] seg_digit
    );
    
    //wire [7:0] display_data; //세그먼트에 출력할 숫자 데이터

    display_FSM_module #(.fsm_cnt_max(FSM_MAX)) display_fsm(.sa_2x2_11(sa_2x2_11), .sa_2x2_12(sa_2x2_12), .sa_2x2_21(sa_2x2_21), .sa_2x2_22(sa_2x2_22), .sa_3x3_11(sa_3x3_11), .sa_3x3_12(sa_3x3_12), .sa_3x3_21(sa_3x3_21), .sa_3x3_22(sa_3x3_22), .clk(clk), .rst(rst), .display_data(display_data));

    display_driver_module #(.driver_cnt_max(DRIVER_MAX)) display_driver(.in(display_data), .clk(clk), .rst(rst), .seg_led(seg_led), .seg_digit(seg_digit));
    
endmodule