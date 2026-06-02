`timescale 1ns / 1ps

// 최상위 모듈: 세 가지 연산 블록 병렬 구동 + 디스플레이 출력 + 검증용 출력
module TOP_Convolution (
    input        clk, rst,
    input  [127:0] flat_image,
    input  [71:0]  flat_kernel,
    
    // 테스트벤치 자동 채점을 위한 검증용 출력 (그대로 유지)
    output [7:0] c11_pe,  c12_pe,  c21_pe,  c22_pe,
    output [7:0] c11_2x2, c12_2x2, c21_2x2, c22_2x2,
    output [7:0] c11_3x3, c12_3x3, c21_3x3, c22_3x3,
    output       done,
    
    // FPGA 보드에 연결될 실제 디스플레이 핀 (추가)
    output [6:0] seg_led,
    output [2:0] seg_digit
);

    wire d1, d2, d3;

    // 세 블록 모두 완료 시 done 신호 생성
    assign done = d1 & d2 & d3;

    // 1. 직렬 단일 PE 블록
    Block_SinglePE u_pe (
        .clk(clk), .rst(rst),
        .flat_image(flat_image), .flat_kernel(flat_kernel),
        .c11_pe(c11_pe), .c12_pe(c12_pe), .c21_pe(c21_pe), .c22_pe(c22_pe),
        .done(d1)
    );

    // 2. 2×2 시스톨릭 어레이 블록
    Block_Array2x2 u_2x2 (
        .clk(clk), .rst(rst),
        .flat_image(flat_image), .flat_kernel(flat_kernel),
        .c11_2x2(c11_2x2), .c12_2x2(c12_2x2), .c21_2x2(c21_2x2), .c22_2x2(c22_2x2),
        .done(d2)
    );

    // 3. 3×3 시스톨릭 어레이 블록
    Block_Array3x3 u_3x3 (
        .clk(clk), .rst(rst),
        .flat_image(flat_image), .flat_kernel(flat_kernel),
        .c11_3x3(c11_3x3), .c12_3x3(c12_3x3), .c21_3x3(c21_3x3), .c22_3x3(c22_3x3),
        .done(d3)
    );

    // 4. 디스플레이 모듈 (연산 결과를 7-Segment로 출력)
    display_module u_display (
        .pe_11(c11_pe), .pe_12(c12_pe), .pe_21(c21_pe), .pe_22(c22_pe),
        .sa_2x2_11(c11_2x2), .sa_2x2_12(c12_2x2), .sa_2x2_21(c21_2x2), .sa_2x2_22(c22_2x2),
        .sa_3x3_11(c11_3x3), .sa_3x3_12(c12_3x3), .sa_3x3_21(c21_3x3), .sa_3x3_22(c22_3x3),
        .clk(clk), 
        .rst(rst),
        .seg_led(seg_led), 
        .seg_digit(seg_digit)
    );

endmodule
