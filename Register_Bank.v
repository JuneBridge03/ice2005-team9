`timescale 1ns / 1ps

module Register_Bank (
    input clk, 
    input rst, 
    input write_en,
    
    // Matrix A Inputs (4x4)
    input [7:0] A11, A12, A13, A14,
    input [7:0] A21, A22, A23, A24,
    input [7:0] A31, A32, A33, A34,
    input [7:0] A41, A42, A43, A44,
    
    // Filter Matrix F Inputs (3x3)
    input [7:0] F11, F12, F13,
    input [7:0] F21, F22, F23,
    input [7:0] F31, F32, F33,
    
    // Stored Outputs (연산기로 전달할 데이터)
    output reg [7:0] outA11, outA12, outA13, outA14,
    output reg [7:0] outA21, outA22, outA23, outA24,
    output reg [7:0] outA31, outA32, outA33, outA34,
    output reg [7:0] outA41, outA42, outA43, outA44,
    
    output reg [7:0] outF11, outF12, outF13,
    output reg [7:0] outF21, outF22, outF23,
    output reg [7:0] outF31, outF32, outF33
);

    // 동기식 리셋 및 쓰기 제어
    always @(posedge clk) begin
        if (rst) begin
            outA11 <= 8'b0; outA12 <= 8'b0; outA13 <= 8'b0; outA14 <= 8'b0;
            outA21 <= 8'b0; outA22 <= 8'b0; outA23 <= 8'b0; outA24 <= 8'b0;
            outA31 <= 8'b0; outA32 <= 8'b0; outA33 <= 8'b0; outA34 <= 8'b0;
            outA41 <= 8'b0; outA42 <= 8'b0; outA43 <= 8'b0; outA44 <= 8'b0;
            outF11 <= 8'b0; outF12 <= 8'b0; outF13 <= 8'b0;
            outF21 <= 8'b0; outF22 <= 8'b0; outF23 <= 8'b0;
            outF31 <= 8'b0; outF32 <= 8'b0; outF33 <= 8'b0;
        end else if (write_en) begin
            outA11 <= A11; outA12 <= A12; outA13 <= A13; outA14 <= A14;
            outA21 <= A21; outA22 <= A22; outA23 <= A23; outA24 <= A24;
            outA31 <= A31; outA32 <= A32; outA33 <= A33; outA34 <= A34;
            outA41 <= A41; outA42 <= A42; outA43 <= A43; outA44 <= A44;
            outF11 <= F11; outF12 <= F12; outF13 <= F13;
            outF21 <= F21; outF22 <= F22; outF23 <= F23;
            outF31 <= F31; outF32 <= F32; outF33 <= F33;
        end
    end

endmodule
