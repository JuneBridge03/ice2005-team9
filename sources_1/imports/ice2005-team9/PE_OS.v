`timescale 1ns / 1ps

// Output Stationary PE (2×2 시스톨릭 어레이용)
// 동작: 로컬 누산기에 in_data×in_filter 를 매 사이클 누적
//       clear=1 이면 다음 사이클에 누산기를 0으로 초기화
module PE_OS (
    input        clk, rst, clear,
    input  [7:0] in_data,
    input  [7:0] in_filter,
    output [7:0] sum_out
);
    wire [7:0] mult_res;  // 곱셈 결과
    wire [7:0] add_res;   // 누산 가산 결과
    wire [7:0] acc_out;   // 누산기 현재 값
    wire [7:0] reg_in;    // 레지스터 입력 (clear 시 0 주입)

    // 곱셈기: in_data × in_filter
    multiplier_8bit u_mult (
        .a(in_data), .b(in_filter), .out(mult_res)
    );

    // 가산기: 누산기 현재값 + 곱셈 결과
    eight_bit_adder u_adder (
        .a(acc_out), .b(mult_res), .s(add_res)
    );

    // clear=1 이면 0, 아니면 누산 결과를 레지스터에 입력
    assign reg_in = clear ? 8'd0 : add_res;

    // 누산기 레지스터 (출력이 입력으로 피드백)
    eight_bit_register_structural_module u_acc_reg (
        .in(reg_in), .clk(clk), .rst(rst), .out(acc_out)
    );

    assign sum_out = acc_out;

endmodule
