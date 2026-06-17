`timescale 1ns / 1ps

// 8비트 레지스터 (1비트 레지스터 8개를 구조적으로 연결)
module eight_bit_register_structural_module (
    input  [7:0] in,
    input        en, clk, rst,
    output [7:0] out
);
    // 각 비트별로 1비트 레지스터 인스턴스화
    one_bit_register_behavioral_module reg0 (.in(in[0]), .en(en), .clk(clk), .rst(rst), .out(out[0]));
    one_bit_register_behavioral_module reg1 (.in(in[1]), .en(en), .clk(clk), .rst(rst), .out(out[1]));
    one_bit_register_behavioral_module reg2 (.in(in[2]), .en(en), .clk(clk), .rst(rst), .out(out[2]));
    one_bit_register_behavioral_module reg3 (.in(in[3]), .en(en), .clk(clk), .rst(rst), .out(out[3]));
    one_bit_register_behavioral_module reg4 (.in(in[4]), .en(en), .clk(clk), .rst(rst), .out(out[4]));
    one_bit_register_behavioral_module reg5 (.in(in[5]), .en(en), .clk(clk), .rst(rst), .out(out[5]));
    one_bit_register_behavioral_module reg6 (.in(in[6]), .en(en), .clk(clk), .rst(rst), .out(out[6]));
    one_bit_register_behavioral_module reg7 (.in(in[7]), .en(en), .clk(clk), .rst(rst), .out(out[7]));

endmodule
