`timescale 1ns / 1ps

// Single PE 블록: PE_FSM과 PE를 묶은 상위 래퍼
// FSM이 PE의 제어 신호와 데이터를 순차적으로 공급하여 C11~C22 계산
module Block_SinglePE (
    input        clk, rst,
    input  [127:0] flat_image,
    input  [71:0]  flat_kernel,
    output [7:0] c11_pe, c12_pe, c21_pe, c22_pe,
    output       done
);
    // FSM ↔ PE 연결 내부 와이어
    wire       pe_clr;
    wire [7:0] pe_din, pe_win, pe_out;

    // FSM: 제어 신호 및 입력 데이터 생성
    PE_CTRL u_pe_fsm (
        .clk(clk), .rst(rst),
        .flat_image(flat_image), .flat_kernel(flat_kernel),
        .pe_out(pe_out),
        .pe_clr(pe_clr), .pe_din(pe_din), .pe_win(pe_win),
        .c11_pe(c11_pe), .c12_pe(c12_pe), .c21_pe(c21_pe), .c22_pe(c22_pe),
        .done(done)
    );

    // PE_WS: 컨트롤러 제어 하에 MAC 연산 수행
    PE_WS u_pe (
        .clk(clk), .rst(rst), .clear(pe_clr),
        .din(pe_din), .win(pe_win), .sin(pe_out),
        .dout(), .out(pe_out)
    );

endmodule
