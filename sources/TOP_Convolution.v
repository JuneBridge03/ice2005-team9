`timescale 1ns / 1ps

// 최상위 모듈: 세 가지 연산 블록을 병렬로 구동
// Single PE, 2×2 SA, 3×3 SA 모두 동일한 입력을 받아 동시에 계산
// done: 세 블록이 모두 완료될 때 high
module TOP_Convolution (
    input        clk, rst,
    input  [127:0] flat_image,
    input  [71:0]  flat_kernel,
    output [7:0] c11_pe,  c12_pe,  c21_pe,  c22_pe,
    output [7:0] c11_2x2, c12_2x2, c21_2x2, c22_2x2,
    output [7:0] c11_3x3, c12_3x3, c21_3x3, c22_3x3,
    output       done
);
    wire d1, d2, d3;

    // 세 블록 모두 완료 시 done 신호 생성
    assign done = d1 & d2 & d3;

    // 직렬 단일 PE 블록
    Block_SinglePE u_pe (
        .clk(clk), .rst(rst),
        .flat_image(flat_image), .flat_kernel(flat_kernel),
        .c11_pe(c11_pe), .c12_pe(c12_pe), .c21_pe(c21_pe), .c22_pe(c22_pe),
        .done(d1)
    );

    // 2×2 시스톨릭 어레이 블록
    Block_Array2x2 u_2x2 (
        .clk(clk), .rst(rst),
        .flat_image(flat_image), .flat_kernel(flat_kernel),
        .c11_2x2(c11_2x2), .c12_2x2(c12_2x2), .c21_2x2(c21_2x2), .c22_2x2(c22_2x2),
        .done(d2)
    );

    // 3×3 시스톨릭 어레이 블록
    Block_Array3x3 u_3x3 (
        .clk(clk), .rst(rst),
        .flat_image(flat_image), .flat_kernel(flat_kernel),
        .c11_3x3(c11_3x3), .c12_3x3(c12_3x3), .c21_3x3(c21_3x3), .c22_3x3(c22_3x3),
        .done(d3)
    );

endmodule
