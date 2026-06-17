`timescale 1ns / 1ps

// 2×2 시스톨릭 어레이 블록: SA2x2_CTRL과 SA2x2를 묶은 상위 래퍼
module Block_Array2x2 (
    input        clk, rst,
    input  [127:0] flat_image,
    input  [71:0]  flat_kernel,
    output [7:0] c11_2x2, c12_2x2, c21_2x2, c22_2x2,
    output       done
);
    // FSM ↔ 어레이 연결 내부 와이어
    wire       pe_clr;
    wire [7:0] systolic_filter_in0, systolic_filter_in1, systolic_data_in0, systolic_data_in1;
    wire [7:0] po1, po2, po3, po4;

    // FSM: 스큐 스케줄링 및 결과 캡처
    SA2x2_CTRL u_fsm (
        .clk(clk), .rst(rst),
        .flat_image(flat_image), .flat_kernel(flat_kernel),
        .pe_out_1(po1), .pe_out_2(po2), .pe_out_3(po3), .pe_out_4(po4),
        .pe_clr(pe_clr),
        .systolic_filter_in0(systolic_filter_in0), .systolic_filter_in1(systolic_filter_in1), .systolic_data_in0(systolic_data_in0), .systolic_data_in1(systolic_data_in1),
        .c11(c11_2x2), .c12(c12_2x2), .c21(c21_2x2), .c22(c22_2x2),
        .done(done)
    );

    // 2×2 시스톨릭 어레이 본체
    SA2x2 u_systolic_array (
        .clk(clk), .rst(rst), .clear(pe_clr),
        .filter1(systolic_filter_in0), .filter2(systolic_filter_in1),
        .in1(systolic_data_in0), .in2(systolic_data_in1),
        .pe_out_1(po1), .pe_out_2(po2), .pe_out_3(po3), .pe_out_4(po4)
    );

endmodule
