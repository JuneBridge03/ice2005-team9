`timescale 1ns / 1ps

// 2×2 Output Stationary 시스톨릭 어레이
// 필터(가중치)는 위→아래, 입력 데이터는 왼→오른쪽으로 흐름
// 각 PE는 로컬 누산기를 가지며 결과를 그 자리에 축적
module SA2x2 (
    input        clk, rst, clear,
    input  [7:0] filter1, filter2, // 필터 행 입력 (왼쪽 열)
    input  [7:0] in1, in2,         // 데이터 행 입력 (상단 행)
    output [7:0] pe_out_1, pe_out_2, pe_out_3, pe_out_4
);
    // 필터 지연 레지스터 (위→아래 1사이클 딜레이)
    wire [7:0] reg_b_11, reg_b_12; // 1행: filter1/filter2 1사이클 지연
    wire [7:0] reg_b_21, reg_b_22; // 2행: filter1/filter2 2사이클 지연

    eight_bit_register_structural_module reg1 (.in(filter1),  .en(1'b1), .clk(clk), .rst(rst), .out(reg_b_11));
    eight_bit_register_structural_module reg2 (.in(filter2),  .en(1'b1), .clk(clk), .rst(rst), .out(reg_b_12));
    eight_bit_register_structural_module reg3 (.in(reg_b_11), .en(1'b1), .clk(clk), .rst(rst), .out(reg_b_21));
    eight_bit_register_structural_module reg4 (.in(reg_b_12), .en(1'b1), .clk(clk), .rst(rst), .out(reg_b_22));

    // 데이터 지연 레지스터 (왼→오른 1사이클 딜레이)
    wire [7:0] reg_a_11, reg_a_21; // 1열: in1/in2 1사이클 지연
    wire [7:0] reg_a_12, reg_a_22; // 2열: in1/in2 2사이클 지연

    eight_bit_register_structural_module reg5 (.in(in1),      .en(1'b1), .clk(clk), .rst(rst), .out(reg_a_11));
    eight_bit_register_structural_module reg6 (.in(in2),      .en(1'b1), .clk(clk), .rst(rst), .out(reg_a_21));
    eight_bit_register_structural_module reg7 (.in(reg_a_11), .en(1'b1), .clk(clk), .rst(rst), .out(reg_a_12));
    eight_bit_register_structural_module reg8 (.in(reg_a_21), .en(1'b1), .clk(clk), .rst(rst), .out(reg_a_22));

    // 4개 PE (Output Stationary): 각자 독립적으로 누산
    PE_OS pe_11 (.clk(clk), .rst(rst), .clear(clear), .in_data(reg_a_11), .in_filter(reg_b_11), .sum_out(pe_out_1));
    PE_OS pe_12 (.clk(clk), .rst(rst), .clear(clear), .in_data(reg_a_12), .in_filter(reg_b_12), .sum_out(pe_out_2));
    PE_OS pe_21 (.clk(clk), .rst(rst), .clear(clear), .in_data(reg_a_21), .in_filter(reg_b_21), .sum_out(pe_out_3));
    PE_OS pe_22 (.clk(clk), .rst(rst), .clear(clear), .in_data(reg_a_22), .in_filter(reg_b_22), .sum_out(pe_out_4));

endmodule
