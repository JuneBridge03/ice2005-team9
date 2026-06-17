`timescale 1ns / 1ps

// 순수 데이터 저장 및 Flat Vector 출력 메모리 (Structural Modeling)
module memory (
    input clk, 
    input rst, 
    input write, // 컨트롤러에서 오는 저장 신호 (레지스터의 en으로 연결됨)
    
    // 개별 8비트 입력 (4x4 이미지)
    input [7:0] A11, A12, A13, A14,
    input [7:0] A21, A22, A23, A24,
    input [7:0] A31, A32, A33, A34,
    input [7:0] A41, A42, A43, A44,
    
    // 개별 8비트 입력 (3x3 커널/필터)
    input [7:0] F11, F12, F13,
    input [7:0] F21, F22, F23,
    input [7:0] F31, F32, F33,

    // TOP_Convolution이 요구하는 통짜(Flat) 출력 양식
    output [127:0] flat_image,
    output [71:0]  flat_kernel
);

    // 각 8비트 레지스터의 출력을 받을 내부 선(wire) 선언
    wire [7:0] oA11, oA12, oA13, oA14;
    wire [7:0] oA21, oA22, oA23, oA24;
    wire [7:0] oA31, oA32, oA33, oA34;
    wire [7:0] oA41, oA42, oA43, oA44;
    
    wire [7:0] oF11, oF12, oF13;
    wire [7:0] oF21, oF22, oF23;
    wire [7:0] oF31, oF32, oF33;

    // 1. 이미지 데이터(16개) 레지스터 구조적 할당
    eight_bit_register_structural_module regA11 (.in(A11), .en(write), .clk(clk), .rst(rst), .out(oA11));
    eight_bit_register_structural_module regA12 (.in(A12), .en(write), .clk(clk), .rst(rst), .out(oA12));
    eight_bit_register_structural_module regA13 (.in(A13), .en(write), .clk(clk), .rst(rst), .out(oA13));
    eight_bit_register_structural_module regA14 (.in(A14), .en(write), .clk(clk), .rst(rst), .out(oA14));
    
    eight_bit_register_structural_module regA21 (.in(A21), .en(write), .clk(clk), .rst(rst), .out(oA21));
    eight_bit_register_structural_module regA22 (.in(A22), .en(write), .clk(clk), .rst(rst), .out(oA22));
    eight_bit_register_structural_module regA23 (.in(A23), .en(write), .clk(clk), .rst(rst), .out(oA23));
    eight_bit_register_structural_module regA24 (.in(A24), .en(write), .clk(clk), .rst(rst), .out(oA24));
    
    eight_bit_register_structural_module regA31 (.in(A31), .en(write), .clk(clk), .rst(rst), .out(oA31));
    eight_bit_register_structural_module regA32 (.in(A32), .en(write), .clk(clk), .rst(rst), .out(oA32));
    eight_bit_register_structural_module regA33 (.in(A33), .en(write), .clk(clk), .rst(rst), .out(oA33));
    eight_bit_register_structural_module regA34 (.in(A34), .en(write), .clk(clk), .rst(rst), .out(oA34));
    
    eight_bit_register_structural_module regA41 (.in(A41), .en(write), .clk(clk), .rst(rst), .out(oA41));
    eight_bit_register_structural_module regA42 (.in(A42), .en(write), .clk(clk), .rst(rst), .out(oA42));
    eight_bit_register_structural_module regA43 (.in(A43), .en(write), .clk(clk), .rst(rst), .out(oA43));
    eight_bit_register_structural_module regA44 (.in(A44), .en(write), .clk(clk), .rst(rst), .out(oA44));

    // 2. 커널/필터 데이터(9개) 레지스터 구조적 할당
    eight_bit_register_structural_module regF11 (.in(F11), .en(write), .clk(clk), .rst(rst), .out(oF11));
    eight_bit_register_structural_module regF12 (.in(F12), .en(write), .clk(clk), .rst(rst), .out(oF12));
    eight_bit_register_structural_module regF13 (.in(F13), .en(write), .clk(clk), .rst(rst), .out(oF13));
    
    eight_bit_register_structural_module regF21 (.in(F21), .en(write), .clk(clk), .rst(rst), .out(oF21));
    eight_bit_register_structural_module regF22 (.in(F22), .en(write), .clk(clk), .rst(rst), .out(oF22));
    eight_bit_register_structural_module regF23 (.in(F23), .en(write), .clk(clk), .rst(rst), .out(oF23));
    
    eight_bit_register_structural_module regF31 (.in(F31), .en(write), .clk(clk), .rst(rst), .out(oF31));
    eight_bit_register_structural_module regF32 (.in(F32), .en(write), .clk(clk), .rst(rst), .out(oF32));
    eight_bit_register_structural_module regF33 (.in(F33), .en(write), .clk(clk), .rst(rst), .out(oF33));

    // 3. 각각의 레지스터에서 뿜어져 나오는 출력들을 플랫 벡터로 단순 결합 (Combinational)
    assign flat_image = { oA11, oA12, oA13, oA14, 
                          oA21, oA22, oA23, oA24, 
                          oA31, oA32, oA33, oA34, 
                          oA41, oA42, oA43, oA44 };
                          
    assign flat_kernel = { oF11, oF12, oF13, 
                           oF21, oF22, oF23, 
                           oF31, oF32, oF33 };

endmodule
