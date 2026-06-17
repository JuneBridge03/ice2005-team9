`timescale 1ns / 1ps

// 3×3 Weight Stationary 시스톨릭 어레이
// 데이터(din)는 왼→오른쪽, 부분합(sin/out)은 위→아래 방향으로 흐름
// 가중치는 각 PE에 고정, 최하단 행(row2)에서 최종 부분합 출력
module SA3x3 (
    input        clk, rst, clear,
    input  [7:0] din0, din1, din2,        // 각 행 데이터 입력
    input  [7:0] win00, win01, win02,     // 0행 가중치
    input  [7:0] win10, win11, win12,     // 1행 가중치
    input  [7:0] win20, win21, win22,     // 2행 가중치
    output [7:0] out20, out21, out22      // 최하단 행 부분합 출력
);
    // 데이터 수평 전달 와이어 (dout → 오른쪽 PE의 din)
    wire [7:0] d00_01, d01_02;
    wire [7:0] d10_11, d11_12;
    wire [7:0] d20_21, d21_22;

    // 부분합 수직 전달 와이어 (out → 아래 PE의 sin)
    wire [7:0] s00_10, s10_20;
    wire [7:0] s01_11, s11_21;
    wire [7:0] s02_12, s12_22;

    // 0행 PE: 최상단, sin=0 (부분합 시작)
    PE_WS pe00 (.clk(clk), .rst(rst), .clear(clear), .din(din0),   .win(win00), .sin(8'd0),   .dout(d00_01), .out(s00_10));
    PE_WS pe01 (.clk(clk), .rst(rst), .clear(clear), .din(d00_01), .win(win01), .sin(8'd0),   .dout(d01_02), .out(s01_11));
    PE_WS pe02 (.clk(clk), .rst(rst), .clear(clear), .din(d01_02), .win(win02), .sin(8'd0),   .dout(),       .out(s02_12));

    // 1행 PE: 0행에서 내려온 부분합 수신
    PE_WS pe10 (.clk(clk), .rst(rst), .clear(clear), .din(din1),   .win(win10), .sin(s00_10), .dout(d10_11), .out(s10_20));
    PE_WS pe11 (.clk(clk), .rst(rst), .clear(clear), .din(d10_11), .win(win11), .sin(s01_11), .dout(d11_12), .out(s11_21));
    PE_WS pe12 (.clk(clk), .rst(rst), .clear(clear), .din(d11_12), .win(win12), .sin(s02_12), .dout(),       .out(s12_22));

    // 2행 PE: 최하단, 최종 부분합을 out20/21/22로 출력
    PE_WS pe20 (.clk(clk), .rst(rst), .clear(clear), .din(din2),   .win(win20), .sin(s10_20), .dout(d20_21), .out(out20));
    PE_WS pe21 (.clk(clk), .rst(rst), .clear(clear), .din(d20_21), .win(win21), .sin(s11_21), .dout(d21_22), .out(out21));
    PE_WS pe22 (.clk(clk), .rst(rst), .clear(clear), .din(d21_22), .win(win22), .sin(s12_22), .dout(),       .out(out22));

endmodule
