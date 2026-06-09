`timescale 1ns / 1ps

// 3×3 시스톨릭 어레이 블록: SA3x3_CTRL과 SA3x3를 묶은 상위 래퍼
module Block_Array3x3 (
    input        clk, rst,
    input  [127:0] flat_image,
    input  [71:0]  flat_kernel,
    output [7:0] c11_3x3, c12_3x3, c21_3x3, c22_3x3,
    output       done
);
    // FSM ↔ 어레이 연결 내부 와이어
    wire       pe_clr;
    wire [7:0] systolic_data_in0, systolic_data_in1, systolic_data_in2;
    wire [7:0] sout20, sout21, sout22;
    wire [7:0] w00, w01, w02, w10, w11, w12, w20, w21, w22;

    // FSM: 스큐 스케줄링, 가중치 할당, 결과 캡처
    SA3x3_CTRL u_fsm (
        .clk(clk), .rst(rst),
        .flat_image(flat_image), .flat_kernel(flat_kernel),
        .sout20(sout20), .sout21(sout21), .sout22(sout22),
        .pe_clr(pe_clr),
        .systolic_data_in0(systolic_data_in0), .systolic_data_in1(systolic_data_in1), .systolic_data_in2(systolic_data_in2),
        .w00(w00), .w01(w01), .w02(w02),
        .w10(w10), .w11(w11), .w12(w12),
        .w20(w20), .w21(w21), .w22(w22),
        .c11_3x3(c11_3x3), .c12_3x3(c12_3x3),
        .c21_3x3(c21_3x3), .c22_3x3(c22_3x3),
        .done(done)
    );

    // 3×3 시스톨릭 어레이 본체
    SA3x3 u_sa3x3 (
        .clk(clk), .rst(rst), .clear(pe_clr),
        .din0(systolic_data_in0), .din1(systolic_data_in1), .din2(systolic_data_in2),
        .win00(w00), .win01(w01), .win02(w02),
        .win10(w10), .win11(w11), .win12(w12),
        .win20(w20), .win21(w21), .win22(w22),
        .out20(sout20), .out21(sout21), .out22(sout22)
    );

endmodule
