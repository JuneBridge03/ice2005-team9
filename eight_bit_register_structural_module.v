`timescale 1ns / 1ps

// 8비트 레지스터 (1비트 레지스터 8개 구조적 연결)
module eight_bit_register_structural_module (in, clk, rst, out);
    input  [7:0] in;
    input        clk, rst;
    output [7:0] out;

    // 각 비트별 1비트 레지스터 인스턴스
    one_bit_register_behavioral_module reg0 (.in(in[0]), .clk(clk), .rst(rst), .out(out[0]));
    one_bit_register_behavioral_module reg1 (.in(in[1]), .clk(clk), .rst(rst), .out(out[1]));
    one_bit_register_behavioral_module reg2 (.in(in[2]), .clk(clk), .rst(rst), .out(out[2]));
    one_bit_register_behavioral_module reg3 (.in(in[3]), .clk(clk), .rst(rst), .out(out[3]));
    one_bit_register_behavioral_module reg4 (.in(in[4]), .clk(clk), .rst(rst), .out(out[4]));
    one_bit_register_behavioral_module reg5 (.in(in[5]), .clk(clk), .rst(rst), .out(out[5]));
    one_bit_register_behavioral_module reg6 (.in(in[6]), .clk(clk), .rst(rst), .out(out[6]));
    one_bit_register_behavioral_module reg7 (.in(in[7]), .clk(clk), .rst(rst), .out(out[7]));

endmodule
